import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient, type User } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

function isStrongPassword(password: string): boolean {
  return (
    password.length >= 8 &&
    /[A-Z]/.test(password) &&
    /[a-z]/.test(password) &&
    /\d/.test(password) &&
    /[^A-Za-z0-9]/.test(password)
  );
}

async function findUserByEmail(
  admin: ReturnType<typeof createClient>,
  email: string,
): Promise<User | null> {
  for (let page = 1; page <= 10; page++) {
    const { data, error } = await admin.auth.admin.listUsers({ page, perPage: 200 });
    if (error) throw error;

    const match = data.users.find((user) => user.email?.toLowerCase() === email);
    if (match) return match;

    if (data.users.length < 200) break;
  }

  return null;
}

async function sendVerificationEmail(
  supabaseUrl: string,
  anonKey: string,
  email: string,
  redirectTo: string,
) {
  const res = await fetch(`${supabaseUrl}/auth/v1/resend`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      apikey: anonKey,
    },
    body: JSON.stringify({
      type: 'signup',
      email,
      options: { email_redirect_to: redirectTo },
    }),
  });

  if (!res.ok) {
    const payload = await res.json().catch(() => ({}));
    throw new Error(payload.msg || payload.message || payload.error_description || 'Failed to send verification email');
  }
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { email, password, name, redirectTo } = await req.json();
    const normalizedEmail = String(email || '').trim().toLowerCase();
    const trimmedName = String(name || '').trim();

    if (!normalizedEmail || !password || !trimmedName) {
      return json({ error: 'Name, email, and password are required' }, 400);
    }

    if (!/^\S+@\S+\.\S+$/.test(normalizedEmail)) {
      return json({ error: 'Enter a valid email address' }, 400);
    }

    if (!isStrongPassword(password)) {
      return json({
        error: 'Use 8+ characters with upper, lower, number, and special character',
      }, 400);
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
    const admin = createClient(supabaseUrl, serviceKey);

    const callbackUrl = redirectTo || `${req.headers.get('origin') || 'http://localhost:3000'}/auth/callback`;

    const { error: createError } = await admin.auth.admin.createUser({
      email: normalizedEmail,
      password,
      email_confirm: false,
      user_metadata: { name: trimmedName },
    });

    if (createError) {
      const duplicate = createError.message.toLowerCase().includes('already');
      if (!duplicate) throw createError;

      const existing = await findUserByEmail(admin, normalizedEmail);
      if (!existing) throw createError;

      if (existing.email_confirmed_at) {
        return json(
          { error: 'An account with this email already exists. Please sign in.', code: 'USER_CONFIRMED' },
          409,
        );
      }

      const { error: updateError } = await admin.auth.admin.updateUserById(existing.id, {
        password,
        email_confirm: false,
        user_metadata: { name: trimmedName },
      });
      if (updateError) throw updateError;
    }

    await sendVerificationEmail(supabaseUrl, anonKey, normalizedEmail, callbackUrl);

    return json({ success: true });
  } catch (err) {
    return json({ error: (err as Error).message }, 500);
  }
});

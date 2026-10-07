import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import {
  authorizeStaffManagement,
  generateTempPassword,
  normalizePhone,
  phoneToAuthEmail,
} from '../_shared/staff_auth.ts';

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

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return json({ error: 'Unauthorized' }, 401);
    }

    const { staff_id } = await req.json().catch(() => ({}));
    if (typeof staff_id !== 'string' || !staff_id) {
      return json({ error: 'staff_id required' }, 400);
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const adminClient = createClient(supabaseUrl, serviceKey);

    const auth = await authorizeStaffManagement(adminClient, authHeader, staff_id);
    if ('error' in auth) {
      return json({ error: auth.error }, auth.status);
    }
    const { staff } = auth;

    if (!staff.phone) {
      return json({ error: 'Staff phone is required' }, 400);
    }

    const normalizedPhone = normalizePhone(staff.phone);
    if (!/^91\d{10}$/.test(normalizedPhone)) {
      return json({ error: 'Enter a valid 10-digit Indian mobile number' }, 400);
    }
    const authEmail = phoneToAuthEmail(normalizedPhone);
    const tempPassword = generateTempPassword();

    if (staff.auth_user_id) {
      const { error: updateError } = await adminClient.auth.admin.updateUserById(
        staff.auth_user_id,
        { password: tempPassword, email: authEmail, email_confirm: true },
      );
      if (updateError) throw updateError;
    } else {
      const { data: authUser, error: createError } = await adminClient.auth.admin.createUser({
        email: authEmail,
        password: tempPassword,
        email_confirm: true,
        user_metadata: { staff_id: staff.id, phone: normalizedPhone, name: staff.name },
      });
      if (createError) {
        if (createError.message.toLowerCase().includes('already')) {
          return json({ error: 'This phone number is already registered to another mechanic account' }, 409);
        }
        throw createError;
      }

      const { error: linkError } = await adminClient
        .from('staff')
        .update({ auth_user_id: authUser.user.id, email: authEmail, phone: normalizedPhone })
        .eq('id', staff_id);
      if (linkError) throw linkError;
    }

    await adminClient
      .from('staff_profiles')
      .upsert({
        staff_id,
        phone: normalizedPhone,
        must_change_password: true,
      }, { onConflict: 'staff_id' });

    await adminClient
      .from('staff')
      .update({ email: authEmail, phone: normalizedPhone })
      .eq('id', staff_id);

    return json({
      phone: normalizedPhone,
      temp_password: tempPassword,
      must_change_password: true,
    });
  } catch (err) {
    console.error('provision-staff-auth error:', err);
    return json({ error: 'Could not provision mechanic login. Please try again.' }, 500);
  }
});

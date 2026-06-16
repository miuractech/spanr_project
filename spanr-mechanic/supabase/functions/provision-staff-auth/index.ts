import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { generateTempPassword, phoneToAuthEmail, normalizePhone } from '../_shared/staff_auth.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const { staff_id } = await req.json();
    if (!staff_id) {
      return new Response(JSON.stringify({ error: 'staff_id required' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;

    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const adminClient = createClient(supabaseUrl, serviceKey);

    const { data: staff, error: staffError } = await userClient
      .from('staff')
      .select('id, company_id, name, phone, email, auth_user_id')
      .eq('id', staff_id)
      .single();

    if (staffError || !staff) {
      return new Response(JSON.stringify({ error: 'Staff not found or access denied' }), {
        status: 403,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    if (!staff.phone) {
      return new Response(JSON.stringify({ error: 'Staff phone is required' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const normalizedPhone = normalizePhone(staff.phone);
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
      if (createError) throw createError;

      await adminClient
        .from('staff')
        .update({ auth_user_id: authUser.user.id, email: authEmail, phone: normalizedPhone })
        .eq('id', staff_id);
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

    return new Response(
      JSON.stringify({
        phone: normalizedPhone,
        temp_password: tempPassword,
        must_change_password: true,
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (err) {
    return new Response(JSON.stringify({ error: (err as Error).message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});

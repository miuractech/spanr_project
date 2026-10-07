import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { authorizeStaffManagement, generateTempPassword } from '../_shared/staff_auth.ts';

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

    if (!staff.auth_user_id) {
      return json({ error: 'Staff not found or not provisioned' }, 403);
    }

    const tempPassword = generateTempPassword();

    const { error: updateError } = await adminClient.auth.admin.updateUserById(
      staff.auth_user_id,
      { password: tempPassword },
    );
    if (updateError) throw updateError;

    await adminClient
      .from('staff_profiles')
      .update({ must_change_password: true })
      .eq('staff_id', staff_id);

    return json({
      phone: staff.phone,
      temp_password: tempPassword,
      must_change_password: true,
    });
  } catch (err) {
    console.error('reset-staff-password error:', err);
    return json({ error: 'Could not reset password. Please try again.' }, 500);
  }
});

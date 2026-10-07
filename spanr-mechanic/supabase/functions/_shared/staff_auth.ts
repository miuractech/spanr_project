import type { SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2';

export function normalizePhone(phone: string): string {
  const digits = phone.replace(/\D/g, '');
  if (digits.length === 10) return `91${digits}`;
  if (digits.length === 12 && digits.startsWith('91')) return digits;
  if (digits.length === 11 && digits.startsWith('0')) return `91${digits.slice(1)}`;
  return digits;
}

export function phoneToAuthEmail(phone: string): string {
  return `${normalizePhone(phone)}@spanr.staff`;
}

export function generateTempPassword(length = 12): string {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789';
  // Rejection sampling: 256 % 55 != 0, so plain modulo would bias the output.
  const limit = 256 - (256 % chars.length);
  const out: string[] = [];
  while (out.length < length) {
    const array = new Uint8Array(length * 2);
    crypto.getRandomValues(array);
    for (const b of array) {
      if (b < limit && out.length < length) out.push(chars[b % chars.length]);
    }
  }
  return out.join('');
}

export type ManagedStaff = {
  id: string;
  company_id: string;
  name: string;
  phone: string | null;
  email: string | null;
  auth_user_id: string | null;
  role: string;
};

/**
 * Resolve the caller from their JWT and confirm they are an enabled owner/admin
 * of the target staff member's company, and that the target is a mechanic.
 * Returns the target staff row, or an error message + HTTP status.
 */
export async function authorizeStaffManagement(
  adminClient: SupabaseClient,
  authHeader: string,
  staffId: string,
): Promise<{ staff: ManagedStaff } | { error: string; status: number }> {
  const jwt = authHeader.replace(/^Bearer\s+/i, '');
  const { data: { user }, error: userError } = await adminClient.auth.getUser(jwt);
  if (userError || !user) return { error: 'Unauthorized', status: 401 };

  const { data: staff } = await adminClient
    .from('staff')
    .select('id, company_id, name, phone, email, auth_user_id, role')
    .eq('id', staffId)
    .maybeSingle();
  if (!staff) return { error: 'Staff not found or access denied', status: 403 };

  const callerQuery = () =>
    adminClient
      .from('staff')
      .select('id, company_id, role')
      .eq('company_id', staff.company_id)
      .eq('enabled', true)
      .in('role', ['owner', 'admin']);

  let { data: caller } = await callerQuery().eq('auth_user_id', user.id).maybeSingle();
  // Legacy email/password owners whose staff row was never linked to auth.users.
  if (!caller && user.email && user.email_confirmed_at) {
    ({ data: caller } = await callerQuery()
      .is('auth_user_id', null)
      .eq('email', user.email)
      .maybeSingle());
  }
  if (!caller) return { error: 'Staff not found or access denied', status: 403 };

  // Only mechanic-app accounts are provisioned here. Never let this endpoint
  // touch an owner/admin login (that would be an account takeover).
  if (staff.role !== 'mechanic' || staff.id === caller.id) {
    return { error: 'This account cannot be managed here', status: 403 };
  }

  return { staff: staff as ManagedStaff };
}

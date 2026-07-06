import supabase from '../supabaseconfig';
import { normalizePhone } from '../core/phone.util';
import type { DbStaff } from '../types';

const OWNER_EMAIL_DOMAIN = 'spanr.owner';

export function phoneToOwnerEmail(phone: string): string {
  return `${normalizePhone(phone)}@${OWNER_EMAIL_DOMAIN}`;
}

export interface AuthUser {
  id: string;
  email: string;
  name: string;
  phone?: string;
  companyId?: string;
}

export function authUsersEqual(a: AuthUser | null, b: AuthUser | null): boolean {
  if (a === b) return true;
  if (!a || !b) return false;
  return a.id === b.id && a.email === b.email && a.name === b.name && a.companyId === b.companyId;
}

// Look up staff by auth_user_id first, then by email
async function findStaffByAuthContext(uid: string, email: string | undefined): Promise<DbStaff | null> {
  // Try auth_user_id first (phone-OTP owners)
  const { data: byUid } = await supabase
    .from('staff')
    .select('id, name, company_id, email, auth_user_id, enabled')
    .eq('auth_user_id', uid)
    .eq('enabled', true)
    .maybeSingle();
  if (byUid) return byUid as DbStaff;

  if (!email) return null;

  // Fallback: email-based lookup (legacy email/password owners)
  const { data: byEmail } = await supabase
    .from('staff')
    .select('id, name, company_id, email, auth_user_id, enabled')
    .eq('email', email)
    .eq('enabled', true)
    .order('created_at', { ascending: false })
    .limit(1)
    .maybeSingle();
  return (byEmail as DbStaff | null) ?? null;
}

export const authService = {
  async sendOtp(phone: string): Promise<void> {
    const normalized = `+${normalizePhone(phone)}`;
    const { error } = await supabase.auth.signInWithOtp({ phone: normalized });
    if (error) throw error;
  },

  async verifyOtp(phone: string, token: string): Promise<AuthUser | null> {
    const normalized = `+${normalizePhone(phone)}`;
    const { data, error } = await supabase.auth.verifyOtp({
      phone: normalized,
      token,
      type: 'sms',
    });
    if (error) throw error;
    if (!data.user) return null;
    return this.getCurrentUser();
  },

  async logout() {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
  },

  async resetPasswordForEmail(email: string) {
    const { error } = await supabase.auth.resetPasswordForEmail(email);
    if (error) throw error;
  },

  async updatePassword(password: string) {
    const { error } = await supabase.auth.updateUser({ password });
    if (error) throw error;
  },

  async getCurrentUser(): Promise<AuthUser | null> {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return null;

    const staffData = await findStaffByAuthContext(user.id, user.email ?? undefined);

    const phone = user.phone ?? undefined;
    const derivedEmail = phone
      ? phoneToOwnerEmail(phone)
      : (user.email ?? '');

    if (staffData) {
      return {
        id: user.id,
        email: staffData.email || derivedEmail,
        name: staffData.name,
        phone,
        companyId: staffData.company_id ?? undefined,
      };
    }

    return {
      id: user.id,
      email: derivedEmail,
      name: user.user_metadata?.name || phone || derivedEmail,
      phone,
    };
  },

  async getSession() {
    const { data: { session } } = await supabase.auth.getSession();
    return session;
  },

  onAuthStateChange(callback: (user: AuthUser | null) => void) {
    let seq = 0;
    return supabase.auth.onAuthStateChange((event, session) => {
      if (event === 'TOKEN_REFRESHED') return;
      const current = ++seq;
      if (session?.user) {
        this.getCurrentUser().then((user) => {
          if (current === seq) callback(user);
        });
      } else {
        seq++;
        callback(null);
      }
    });
  },

  async getStaffByEmail(email: string): Promise<DbStaff | null> {
    const { data, error } = await supabase
      .from('staff')
      .select('*')
      .eq('email', email)
      .eq('enabled', true)
      .order('created_at', { ascending: false })
      .limit(1)
      .maybeSingle();
    if (error) return null;
    return data;
  },
};

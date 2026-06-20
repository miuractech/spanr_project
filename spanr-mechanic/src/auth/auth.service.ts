import supabase from '../supabaseconfig';
import type { DbStaff } from '../types';
import { authCallbackUrl, resetPasswordUrl, isEmailVerified } from './auth.util';

export interface SignUpData {
  email: string;
  password: string;
  name: string;
}

export interface LoginData {
  email: string;
  password: string;
}

export interface SignUpResult {
  requiresVerification: boolean;
}

export interface AuthUser {
  id: string;
  email: string;
  name: string;
  companyId?: string;
}

export function authUsersEqual(a: AuthUser | null, b: AuthUser | null): boolean {
  if (a === b) return true;
  if (!a || !b) return false;
  return (
    a.id === b.id &&
    a.email === b.email &&
    a.name === b.name &&
    a.companyId === b.companyId
  );
}

const staffByEmailQuery = (email: string) =>
  supabase
    .from('staff')
    .select('id, name, company_id, enabled')
    .eq('email', email)
    .eq('enabled', true)
    .order('created_at', { ascending: false })
    .limit(1)
    .maybeSingle();

export const authService = {
  async signUp(data: SignUpData): Promise<SignUpResult> {
    const { data: result, error } = await supabase.functions.invoke('signup-owner', {
      body: {
        email: data.email.trim().toLowerCase(),
        password: data.password,
        name: data.name.trim(),
        redirectTo: authCallbackUrl(),
      },
    });

    const payload = result as { error?: string; code?: string; success?: boolean } | null;
    if (payload?.error) {
      throw new Error(payload.error);
    }

    if (error) {
      const httpContext = (error as { context?: Response }).context;
      if (httpContext instanceof Response) {
        try {
          const body = await httpContext.clone().json() as { error?: string };
          if (body?.error) throw new Error(body.error);
        } catch (parseError) {
          if (parseError instanceof Error && parseError.message !== error.message) {
            throw parseError;
          }
        }
      }
      throw new Error(error.message || 'Signup failed');
    }

    await supabase.auth.signOut();

    return { requiresVerification: true };
  },

  async resetPasswordForEmail(email: string) {
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: resetPasswordUrl(),
    });
    if (error) throw error;
  },

  async updatePassword(password: string) {
    const { error } = await supabase.auth.updateUser({ password });
    if (error) throw error;
  },

  async resendVerificationEmail(email: string) {
    const { error } = await supabase.auth.resend({
      type: 'signup',
      email,
      options: {
        emailRedirectTo: authCallbackUrl(),
      },
    });
    if (error) throw error;
  },

  async login(data: LoginData) {
    const { data: authData, error } = await supabase.auth.signInWithPassword({
      email: data.email,
      password: data.password,
    });

    if (error) throw error;

    if (!isEmailVerified(authData.user)) {
      await supabase.auth.signOut();
      throw new Error('Email not confirmed');
    }

    return authData;
  },

  async logout() {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
  },

  async getCurrentUser(): Promise<AuthUser | null> {
    const { data: { user } } = await supabase.auth.getUser();

    if (!user) return null;

    if (!isEmailVerified(user)) {
      return null;
    }

    const { data: staffData, error: staffError } = await staffByEmailQuery(user.email!);

    if (staffError) {
      console.error('Error fetching staff data:', staffError);
    }

    if (staffData) {
      return {
        id: user.id,
        email: user.email!,
        name: staffData.name,
        companyId: staffData.company_id,
      };
    }

    return {
      id: user.id,
      email: user.email!,
      name: user.user_metadata?.name || user.email!,
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

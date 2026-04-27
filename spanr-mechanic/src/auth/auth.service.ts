import supabase from '../supabaseconfig';
import type { DbStaff } from '../types';

export interface SignUpData {
  email: string;
  password: string;
  name: string;
}

export interface LoginData {
  email: string;
  password: string;
}

export interface AuthUser {
  id: string;
  email: string;
  name: string;
  companyId?: string;
}

export const authService = {
  async signUp(data: SignUpData) {
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: data.email,
      password: data.password,
      options: {
        data: {
          name: data.name,
        },
        emailRedirectTo: undefined,
      },
    });

    if (authError) throw authError;
    if (!authData.user) throw new Error('User creation failed');

    return authData;
  },

  async login(data: LoginData) {
    const { data: authData, error } = await supabase.auth.signInWithPassword({
      email: data.email,
      password: data.password,
    });

    if (error) throw error;
    return authData;
  },

  async logout() {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
  },

  async getCurrentUser(): Promise<AuthUser | null> {
    const { data: { user } } = await supabase.auth.getUser();
    
    if (!user) return null;

    // Check if user is staff member
    const { data: staffData, error: staffError } = await supabase
      .from('staff')
      .select('id, name, company_id, enabled')
      .eq('email', user.email)
      .eq('enabled', true)
      .maybeSingle();

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
      .maybeSingle();

    if (error) return null;
    return data;
  },
};


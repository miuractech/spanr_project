import supabase from '../supabaseconfig';
import { companyService, type DbCompanyDocument } from '../company/company.service';
import type { DbMechanicCompany } from '../types';

export interface AdminCompanyRow extends DbMechanicCompany {
  document_count: number;
}

export const adminService = {
  async signIn(email: string, password: string) {
    const { error } = await supabase.auth.signInWithPassword({
      email: email.trim(),
      password,
    });
    if (error) throw error;
  },

  async signOut() {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
  },

  async amISuperAdmin(): Promise<boolean> {
    const { data: { session } } = await supabase.auth.getSession();
    if (!session) return false;
    const { data, error } = await supabase.rpc('am_i_super_admin');
    if (error) {
      console.error('am_i_super_admin failed', error);
      return false;
    }
    return !!data;
  },

  async hasAnyAdmin(): Promise<boolean> {
    const { data, error } = await supabase.rpc('has_any_admin');
    if (error) {
      const { data: rows, error: selectError } = await supabase
        .from('admin_users')
        .select('user_id')
        .limit(1);
      if (selectError) return true;
      return (rows?.length ?? 0) > 0;
    }
    return !!data;
  },

  async claimFirstAdmin(email: string): Promise<void> {
    const { error } = await supabase.rpc('admin_add_admin', { target_email: email });
    if (error) throw error;
  },

  async listCompanies(status?: 'pending' | 'verified' | 'rejected'): Promise<AdminCompanyRow[]> {
    let query = supabase
      .from('mechanic_companies')
      .select('*')
      .order('created_at', { ascending: false });

    if (status) query = query.eq('verification_status', status);

    const { data, error } = await query;
    if (error) throw error;

    return (data ?? []).map((row) => ({
      ...(row as DbMechanicCompany),
      document_count: 0,
    }));
  },

  async getCompany(companyId: string): Promise<DbMechanicCompany> {
    const { data, error } = await supabase
      .from('mechanic_companies')
      .select('*')
      .eq('id', companyId)
      .single();
    if (error) throw error;
    return data as DbMechanicCompany;
  },

  async getCompanyDocuments(companyId: string): Promise<DbCompanyDocument[]> {
    return companyService.getDocuments(companyId);
  },

  async setCompanyVerification(
    companyId: string,
    status: 'pending' | 'verified' | 'rejected',
    notes?: string
  ): Promise<void> {
    const { error } = await supabase.rpc('admin_set_company_verification', {
      p_company_id: companyId,
      p_status: status,
      p_notes: notes ?? null,
    });
    if (error) throw error;
  },

  async setDocumentVerification(
    documentId: string,
    status: 'pending' | 'verified' | 'rejected',
    reason?: string
  ): Promise<void> {
    const { error } = await supabase.rpc('admin_set_document_verification', {
      p_document_id: documentId,
      p_status: status,
      p_reason: reason ?? null,
    });
    if (error) throw error;
  },
};

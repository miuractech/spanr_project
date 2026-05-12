import supabase from '../supabaseconfig';
import type { DbStaff } from '../types';

export interface StaffFormData {
  name: string;
  email: string;
  enabled: boolean;
}

export interface StaffWithAccess extends DbStaff {
  permissions: string[];
}

export const staffService = {
  async getStaffByCompany(companyId: string): Promise<StaffWithAccess[]> {
    const { data, error } = await supabase
      .from('staff')
      .select(`
        *,
        staff_access(access_permission)
      `)
      .eq('company_id', companyId)
      .order('created_at', { ascending: false });

    if (error) throw error;

    return (data || []).map((staff: any) => ({
      ...staff,
      permissions: staff.staff_access?.map((sa: any) => sa.access_permission) || [],
    }));
  },

  async createStaff(companyId: string, data: StaffFormData): Promise<DbStaff> {
    const { data: staff, error } = await supabase
      .from('staff')
      .insert({
        company_id: companyId,
        name: data.name,
        email: data.email,
        enabled: data.enabled,
      })
      .select()
      .single();

    if (error) throw error;
    return staff;
  },

  async updateStaff(staffId: string, data: Partial<StaffFormData>): Promise<DbStaff> {
    const { data: staff, error } = await supabase
      .from('staff')
      .update({
        name: data.name,
        email: data.email,
        enabled: data.enabled,
      })
      .eq('id', staffId)
      .select()
      .single();

    if (error) throw error;
    return staff;
  },

  async deleteStaff(staffId: string): Promise<void> {
    const { error } = await supabase
      .from('staff')
      .delete()
      .eq('id', staffId);

    if (error) throw error;
  },

  async addPermission(staffId: string, permission: string): Promise<void> {
    const { error } = await supabase
      .from('staff_access')
      .insert({
        staff_id: staffId,
        access_permission: permission,
      });

    if (error) throw error;
  },

  async removePermission(staffId: string, permission: string): Promise<void> {
    const { error } = await supabase
      .from('staff_access')
      .delete()
      .eq('staff_id', staffId)
      .eq('access_permission', permission);

    if (error) throw error;
  },

  async updatePermissions(staffId: string, permissions: string[]): Promise<void> {
    // Delete all existing permissions
    await supabase
      .from('staff_access')
      .delete()
      .eq('staff_id', staffId);

    // Add new permissions
    if (permissions.length > 0) {
      const { error } = await supabase
        .from('staff_access')
        .insert(permissions.map(p => ({ staff_id: staffId, access_permission: p })));

      if (error) throw error;
    }
  },
};


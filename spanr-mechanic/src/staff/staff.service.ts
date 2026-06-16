import supabase from '../supabaseconfig';
import type { DbStaff, DbStaffProfile, StaffAvailability } from '../types';
import { normalizePhone, phoneToAuthEmail } from '../core/phone.util';

export interface StaffFormData {
  name: string;
  email?: string;
  enabled: boolean;
  phone: string;
  experienceYears?: number;
  availability?: StaffAvailability;
  skills?: string[];
}

export interface StaffCredentials {
  phone: string;
  tempPassword: string;
}

export interface StaffWithAccess extends DbStaff {
  permissions: string[];
  profile?: DbStaffProfile;
  skills?: string[];
}

export const staffService = {
  async getStaffByCompany(companyId: string): Promise<StaffWithAccess[]> {
    const { data, error } = await supabase
      .from('staff')
      .select(`
        *,
        staff_access(access_permission),
        staff_profiles(*),
        staff_skills(skill_name)
      `)
      .eq('company_id', companyId)
      .order('created_at', { ascending: false });

    if (error) throw error;

    return (data || []).map((staff: any) => ({
      ...staff,
      permissions: staff.staff_access?.map((sa: any) => sa.access_permission) || [],
      profile: Array.isArray(staff.staff_profiles) ? staff.staff_profiles[0] : staff.staff_profiles,
      skills: staff.staff_skills?.map((s: any) => s.skill_name) || [],
    }));
  },

  async createStaff(companyId: string, data: StaffFormData): Promise<{ staff: DbStaff; credentials: StaffCredentials }> {
    const phone = normalizePhone(data.phone);
    const email = phoneToAuthEmail(phone);

    const { data: staff, error } = await supabase
      .from('staff')
      .insert({
        company_id: companyId,
        name: data.name,
        email,
        phone,
        enabled: data.enabled,
      })
      .select()
      .single();

    if (error) throw error;
    await staffService.upsertProfile(staff.id, data);
    if (data.skills) await staffService.setSkills(staff.id, data.skills);

    const credentials = await staffService.provisionAuth(staff.id);
    return { staff, credentials };
  },

  async updateStaff(staffId: string, data: Partial<StaffFormData>): Promise<DbStaff> {
    const updates: Record<string, unknown> = {
      name: data.name,
      enabled: data.enabled,
    };

    const { data: staff, error } = await supabase
      .from('staff')
      .update(updates)
      .eq('id', staffId)
      .select()
      .single();

    if (error) throw error;
    await staffService.upsertProfile(staffId, data);
    if (data.skills) await staffService.setSkills(staffId, data.skills);
    return staff;
  },

  async provisionAuth(staffId: string): Promise<StaffCredentials> {
    const { data, error } = await supabase.functions.invoke('provision-staff-auth', {
      body: { staff_id: staffId },
    });
    if (error) throw error;
    if (data?.error) throw new Error(data.error);
    return {
      phone: data.phone,
      tempPassword: data.temp_password,
    };
  },

  async resetPassword(staffId: string): Promise<StaffCredentials> {
    const { data, error } = await supabase.functions.invoke('reset-staff-password', {
      body: { staff_id: staffId },
    });
    if (error) throw error;
    if (data?.error) throw new Error(data.error);
    return {
      phone: data.phone,
      tempPassword: data.temp_password,
    };
  },

  async upsertProfile(staffId: string, data: Partial<StaffFormData>): Promise<void> {
    const { error } = await supabase
      .from('staff_profiles')
      .upsert({
        staff_id: staffId,
        phone: data.phone ? normalizePhone(data.phone) : undefined,
        experience_years: data.experienceYears ?? 0,
        availability: data.availability ?? 'available',
      }, { onConflict: 'staff_id' });

    if (error) throw error;
  },

  async setSkills(staffId: string, skills: string[]): Promise<void> {
    await supabase.from('staff_skills').delete().eq('staff_id', staffId);
    if (skills.length === 0) return;
    const { error } = await supabase
      .from('staff_skills')
      .insert(skills.map((skill_name) => ({ staff_id: staffId, skill_name })));
    if (error) throw error;
  },

  async uploadStaffPhoto(staffId: string, file: File): Promise<string> {
    const ext = file.name.split('.').pop();
    const path = `${staffId}/${Date.now()}.${ext}`;
    const { error: uploadError } = await supabase.storage.from('staff-photos').upload(path, file);
    if (uploadError) throw uploadError;
    const { data: { publicUrl } } = supabase.storage.from('staff-photos').getPublicUrl(path);
    await supabase.from('staff_profiles').upsert({ staff_id: staffId, photo_url: publicUrl }, { onConflict: 'staff_id' });
    return publicUrl;
  },

  async deleteStaff(staffId: string): Promise<void> {
    const { error } = await supabase.from('staff').delete().eq('id', staffId);
    if (error) throw error;
  },

  async addPermission(staffId: string, permission: string): Promise<void> {
    const { error } = await supabase
      .from('staff_access')
      .insert({ staff_id: staffId, access_permission: permission });
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
    await supabase.from('staff_access').delete().eq('staff_id', staffId);
    if (permissions.length > 0) {
      const { error } = await supabase
        .from('staff_access')
        .insert(permissions.map(p => ({ staff_id: staffId, access_permission: p })));
      if (error) throw error;
    }
  },
};

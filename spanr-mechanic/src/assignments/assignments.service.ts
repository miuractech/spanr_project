import supabase from '../supabaseconfig';
import { isStaffAuthEmail } from '../core/phone.util';
import type { OrderAssignment, StaffWorkload } from './assignments.types';

export const assignmentsService = {
  async getAssignmentByOrder(orderId: string): Promise<OrderAssignment | null> {
    const { data, error } = await supabase
      .from('order_assignments')
      .select(`
        *,
        staff:staff_id (id, name, email)
      `)
      .eq('order_id', orderId)
      .eq('status', 'active')
      .maybeSingle();

    if (error) throw error;
    return data;
  },

  async assignOrder(orderId: string, staffId: string, notes?: string): Promise<string> {
    const { data, error } = await supabase.rpc('assign_order_to_staff', {
      p_order_id: orderId,
      p_staff_id: staffId,
      p_notes: notes ?? null,
    });

    if (error) throw error;
    return data as string;
  },

  async getCompanyWorkload(companyId: string): Promise<StaffWorkload[]> {
    const { data: workload, error } = await supabase
      .from('staff_workload')
      .select('*')
      .eq('company_id', companyId)
      .eq('enabled', true);

    if (error) throw error;

    const staffIds = (workload ?? []).map((w) => w.staff_id);
    if (staffIds.length === 0) return [];

    const { data: skills } = await supabase
      .from('staff_skills')
      .select('staff_id, skill_name')
      .in('staff_id', staffIds);

    const skillsMap = new Map<string, string[]>();
    (skills ?? []).forEach((s) => {
      const list = skillsMap.get(s.staff_id) ?? [];
      list.push(s.skill_name);
      skillsMap.set(s.staff_id, list);
    });

    return (workload ?? [])
      .filter((w) => isStaffAuthEmail(w.email))
      .map((w) => ({
        ...w,
        skills: skillsMap.get(w.staff_id) ?? [],
      }));
  },

  async getAssignmentHistory(orderId: string): Promise<OrderAssignment[]> {
    const { data, error } = await supabase
      .from('order_assignments')
      .select(`
        *,
        staff:staff_id (id, name, email)
      `)
      .eq('order_id', orderId)
      .order('assigned_at', { ascending: false });

    if (error) throw error;
    return data ?? [];
  },
};

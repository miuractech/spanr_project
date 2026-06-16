export type AssignmentStatus = 'active' | 'reassigned' | 'completed' | 'cancelled';
export type StaffAvailability = 'available' | 'busy' | 'off';

export interface OrderAssignment {
  id: string;
  order_id: string;
  staff_id: string;
  assigned_by?: string;
  status: AssignmentStatus;
  notes?: string;
  assigned_at: string;
  ended_at?: string;
  staff?: {
    id: string;
    name: string;
    email: string;
  };
}

export interface StaffWorkload {
  staff_id: string;
  company_id: string;
  name: string;
  email: string;
  enabled: boolean;
  availability: StaffAvailability;
  active_jobs: number;
  skills?: string[];
}

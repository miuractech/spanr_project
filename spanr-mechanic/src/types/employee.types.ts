/**
 * Employee/Staff-related type definitions
 */

export type StaffType = {
  email: string;
  name: string;
  access: string[];
  id: string;
  enabled: boolean;
};

// Database table type
export interface DbStaff {
  id: string;
  company_id: string;
  email: string;
  name: string;
  enabled: boolean;
  created_at: string;
  updated_at: string;
}

export interface DbStaffAccess {
  id: string;
  staff_id: string;
  access_permission: string;
  created_at: string;
}


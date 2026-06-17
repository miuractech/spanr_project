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
  phone?: string;
  enabled: boolean;
  auth_user_id?: string;
  created_at: string;
  updated_at: string;
}

export interface DbStaffAccess {
  id: string;
  staff_id: string;
  access_permission: string;
  created_at: string;
}

export type StaffAvailability = 'available' | 'busy' | 'off';

export interface DbStaffProfile {
  id: string;
  staff_id: string;
  phone?: string;
  experience_years: number;
  photo_url?: string;
  availability: StaffAvailability;
  bio?: string;
  must_change_password?: boolean;
  created_at: string;
  updated_at: string;
}

export interface DbStaffSkill {
  id: string;
  staff_id: string;
  skill_name: string;
  created_at: string;
}

export interface DbStaffCertificate {
  id: string;
  staff_id: string;
  name: string;
  file_url: string;
  expiry_date?: string;
  created_at: string;
}

export interface DbStaffCourse {
  id: string;
  staff_id: string;
  course_name: string;
  institution?: string;
  completed_date?: string;
  created_at: string;
}


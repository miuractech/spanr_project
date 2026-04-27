/**
 * Company and Address-related type definitions
 */

export interface AddressType {
  address_line_1: string;
  address_line_2: string;
  landmark: string;
  city: string;
  state: string;
  phone_number: string;
  pincode: string;
}

export interface MechanicCompanyProfile {
  id: string;
  company_name: string;
  address: AddressType;
  phone: string;
  email: string;
  services_offered: string[];
  ratings: {
    count: number;
    professionalism: number;
    timeliness: number;
    quality: number;
    rating: number;
  };
  logo: string;
  certifications: string[];
  specializations: string[];
  created_at: string;
  updated_at: string;
}

// Database table type
export interface DbMechanicCompany {
  id: string;
  company_name: string;
  address_line_1: string;
  address_line_2: string;
  landmark: string;
  city: string;
  state: string;
  phone_number: string;
  pincode: string;
  phone: string;
  email: string;
  logo: string | null;
  latitude: number | null;
  longitude: number | null;
  images: string[];
  created_at: string;
  updated_at: string;
}

export interface DbCompanyRating {
  id: string;
  company_id: string;
  count: number;
  professionalism: number;
  timeliness: number;
  quality: number;
  rating: number;
  updated_at: string;
}

export interface DbCompanyCertification {
  id: string;
  company_id: string;
  certification_name: string;
  created_at: string;
}

export interface DbCompanySpecialization {
  id: string;
  company_id: string;
  specialization_name: string;
  created_at: string;
}


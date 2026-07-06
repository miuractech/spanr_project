/**
 * Plan and Service-related type definitions
 */

export type MasterVehicleType = 'car' | 'bike';

export type FuelType = 'diesel' | 'petrol';

export type LocationType = 'in_premise' | 'shed';

export type FaqType = { 
  question: string; 
  answer: string 
};

export type ServiceOutcomeType = {
  title: string;
  image: string;
  description: string;
};

export interface MasterServicesType {
  value: string;
  id: string;
  category: MasterVehicleType;
  icon: React.ReactNode;
}

export interface MasterPlanType {
  service_id: string;
  plan_id: string;
  vehicle: MasterVehicleType;
  fuel_type: FuelType[];
  location: LocationType;
  duration: number;
  base_price: number;
  warranty: string;
  guarantee: string;
  features: string[];
  images: string[];
  faqs: FaqType[];
  badge: string;
  service_outcome: ServiceOutcomeType[];
  additional_services: string[];
  steps: string[];
  name: string;
  tax: number;
}

// Database table types
export interface DbService {
  id: string;
  company_id: string;
  name: string;
  description?: string | null;
  category: MasterVehicleType;
  icon_url: string | null;
  created_at: string;
  updated_at: string;
}

export interface DbPlan {
  id: string;
  service_id: string;
  company_id: string;
  name: string;
  vehicle_type: MasterVehicleType;
  location_type: LocationType;
  duration: number;
  base_price: number;
  tax: number;
  warranty: string;
  guarantee: string;
  badge: string | null;
  plan_type: 'package' | 'custom';
  package_tier: 1 | 2 | 3 | null;
  created_at: string;
  updated_at: string;
}

export interface DbPlanFuelType {
  id: string;
  plan_id: string;
  fuel_type: FuelType;
}

export interface DbPlanFeature {
  id: string;
  plan_id: string;
  feature: string;
  display_order: number;
}

export interface DbPlanFaq {
  id: string;
  plan_id: string;
  question: string;
  answer: string;
  display_order: number;
}

export interface DbPlanServiceOutcome {
  id: string;
  plan_id: string;
  title: string;
  image_url: string;
  description: string;
  display_order: number;
}

export interface DbPlanAdditionalService {
  id: string;
  plan_id: string;
  service_name: string;
  display_order: number;
}

export interface DbPlanStep {
  id: string;
  plan_id: string;
  step_description: string;
  display_order: number;
}


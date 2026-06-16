/**
 * Order-related type definitions
 */

export interface LocationType {
  latitude: number;
  longitude: number;
  address: string;
}

export interface VehicleData {
  vehicle_id: string;
  make: string;
  model: string;
  year: number;
  license_plate: string;
}

export interface UserDataType {
  user_id: string;
  name: string;
  phone: string;
  email: string;
  location: LocationType;
  vehicle: VehicleData;
}

export type OrderStatus = 'created' | 'accepted' | 'assigned' | 'in_progress' | 'waiting_for_parts' | 'ready_for_delivery' | 'completed' | 'dispute' | 'cancelled';
export type PaymentMethod = 'credit_card' | 'debit_card' | 'net_banking' | 'upi';
export type PaymentStatus = 'paid' | 'unpaid';

export interface OrderType {
  order_id: string;
  user: UserDataType;
  plan: {
    plan_id: string;
    name: string;
  };
  order_date: string;
  scheduled_service_date: string;
  status: OrderStatus;
  payment: {
    method: PaymentMethod;
    status: PaymentStatus;
    amount: number;
  };
  contact_details: {
    name: string;
    phone: string;
    email: string;
    address: string;
  };
  special_instructions?: string;
}

// Database table types
export interface DbVehicle {
  id: string;
  user_id: string;
  make: string;
  model: string;
  year: number;
  license_plate: string;
  created_at: string;
  updated_at: string;
}

export interface DbOrder {
  id: string;
  company_id: string;
  user_id: string;
  plan_id: string;
  vehicle_id: string;
  order_date: string;
  scheduled_service_date: string;
  status: OrderStatus;
  special_instructions: string | null;
  contact_name: string;
  contact_phone: string;
  contact_email: string;
  contact_address: string;
  service_latitude: number;
  service_longitude: number;
  service_address: string;
  created_at: string;
  updated_at: string;
}

export interface DbPayment {
  id: string;
  order_id: string;
  method: PaymentMethod;
  status: PaymentStatus;
  amount: number;
  transaction_id: string | null;
  paid_at: string | null;
  created_at: string;
  updated_at: string;
}


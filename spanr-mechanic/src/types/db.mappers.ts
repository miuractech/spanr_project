/**
 * Database Mappers - Convert between DB snake_case and App camelCase
 * 
 * These helpers convert between Supabase database types (snake_case) 
 * and application types (camelCase).
 */

import type {
  DbUser,
  DbMechanicCompany,
  DbCompanyRating,
  DbStaff,
  DbService,
  DbPlan,
  DbPlanFeature,
  DbPlanFaq,
  DbVehicle,
  DbOrder,
  DbPayment,
  UserDataType,
  VehicleData,
  OrderType,
  OrderStatus,
  PaymentMethod,
  PaymentStatus,
  MechanicCompanyProfile,
  AddressType,
} from './index';

// ===========================================
// Company Mappers
// ===========================================

export function dbCompanyToProfile(
  dbCompany: DbMechanicCompany,
  ratings?: DbCompanyRating,
  certifications?: string[],
  specializations?: string[],
  servicesOffered?: string[]
): MechanicCompanyProfile {
  return {
    id: dbCompany.id,
    company_name: dbCompany.company_name,
    address: {
      address_line_1: dbCompany.address_line_1,
      address_line_2: dbCompany.address_line_2,
      landmark: dbCompany.landmark,
      city: dbCompany.city,
      state: dbCompany.state,
      phone_number: dbCompany.phone_number,
      pincode: dbCompany.pincode,
    },
    phone: dbCompany.phone,
    email: dbCompany.email,
    services_offered: servicesOffered || [],
    ratings: ratings ? {
      count: ratings.count,
      professionalism: ratings.professionalism,
      timeliness: ratings.timeliness,
      quality: ratings.quality,
      rating: ratings.rating,
    } : {
      count: 0,
      professionalism: 0,
      timeliness: 0,
      quality: 0,
      rating: 0,
    },
    logo: dbCompany.logo || '',
    certifications: certifications || [],
    specializations: specializations || [],
    created_at: dbCompany.created_at,
    updated_at: dbCompany.updated_at,
  };
}

export function profileToDbCompany(profile: MechanicCompanyProfile): Omit<DbMechanicCompany, 'created_at' | 'updated_at'> {
  return {
    id: profile.id,
    company_name: profile.company_name,
    address_line_1: profile.address.address_line_1,
    address_line_2: profile.address.address_line_2,
    landmark: profile.address.landmark,
    city: profile.address.city,
    state: profile.address.state,
    phone_number: profile.address.phone_number,
    pincode: profile.address.pincode,
    phone: profile.phone,
    email: profile.email,
    logo: profile.logo || null,
  };
}

// ===========================================
// Vehicle Mappers
// ===========================================

export function dbVehicleToApp(dbVehicle: DbVehicle): VehicleData {
  return {
    vehicle_id: dbVehicle.id,
    make: dbVehicle.make,
    model: dbVehicle.model,
    year: dbVehicle.year,
    license_plate: dbVehicle.license_plate,
  };
}

export function appVehicleToDb(vehicle: VehicleData, userId: string): Omit<DbVehicle, 'created_at' | 'updated_at'> {
  return {
    id: vehicle.vehicle_id,
    user_id: userId,
    make: vehicle.make,
    model: vehicle.model,
    year: vehicle.year,
    license_plate: vehicle.license_plate,
  };
}

// ===========================================
// Order Mappers
// ===========================================

export interface DbOrderWithDetails extends DbOrder {
  user_name: string;
  user_email: string;
  user_phone: string;
  vehicle_make: string;
  vehicle_model: string;
  vehicle_year: number;
  license_plate: string;
  plan_name: string;
  company_name: string;
  payment_status?: PaymentStatus;
  payment_method?: PaymentMethod;
  payment_amount?: number;
}

export function dbOrderToApp(dbOrder: DbOrderWithDetails): OrderType {
  return {
    order_id: dbOrder.id,
    user: {
      user_id: dbOrder.user_id,
      name: dbOrder.user_name,
      phone: dbOrder.user_phone,
      email: dbOrder.user_email,
      location: {
        latitude: dbOrder.service_latitude,
        longitude: dbOrder.service_longitude,
        address: dbOrder.service_address,
      },
      vehicle: {
        vehicle_id: dbOrder.vehicle_id,
        make: dbOrder.vehicle_make,
        model: dbOrder.vehicle_model,
        year: dbOrder.vehicle_year,
        license_plate: dbOrder.license_plate,
      },
    },
    plan: {
      plan_id: dbOrder.plan_id,
      name: dbOrder.plan_name,
    },
    order_date: dbOrder.order_date,
    scheduled_service_date: dbOrder.scheduled_service_date,
    status: dbOrder.status,
    payment: {
      method: dbOrder.payment_method || 'upi',
      status: dbOrder.payment_status || 'unpaid',
      amount: dbOrder.payment_amount || 0,
    },
    contact_details: {
      name: dbOrder.contact_name,
      phone: dbOrder.contact_phone,
      email: dbOrder.contact_email,
      address: dbOrder.contact_address,
    },
    special_instructions: dbOrder.special_instructions || undefined,
  };
}

export function appOrderToDb(
  order: OrderType,
  companyId: string,
  userId: string,
  vehicleId: string
): Omit<DbOrder, 'created_at' | 'updated_at'> {
  return {
    id: order.order_id,
    company_id: companyId,
    user_id: userId,
    plan_id: order.plan.plan_id,
    vehicle_id: vehicleId,
    order_date: order.order_date,
    scheduled_service_date: order.scheduled_service_date,
    status: order.status,
    special_instructions: order.special_instructions || null,
    contact_name: order.contact_details.name,
    contact_phone: order.contact_details.phone,
    contact_email: order.contact_details.email,
    contact_address: order.contact_details.address,
    service_latitude: order.user.location.latitude,
    service_longitude: order.user.location.longitude,
    service_address: order.user.location.address,
  };
}

// ===========================================
// Payment Mappers
// ===========================================

export function appPaymentToDb(
  orderId: string,
  payment: OrderType['payment']
): Omit<DbPayment, 'id' | 'created_at' | 'updated_at' | 'transaction_id' | 'paid_at'> {
  return {
    order_id: orderId,
    method: payment.method,
    status: payment.status,
    amount: payment.amount,
  };
}

// ===========================================
// Plan Mappers (with related data)
// ===========================================

export interface DbPlanWithDetails extends DbPlan {
  service_name: string;
  company_name: string;
  fuel_types: string[];
  features: DbPlanFeature[];
  faqs: DbPlanFaq[];
  rating?: number;
}

export interface AppPlanWithDetails {
  plan_id: string;
  service_id: string;
  company_id: string;
  name: string;
  service_name: string;
  company_name: string;
  vehicle_type: 'car' | 'bike';
  location_type: 'in_premise' | 'shed';
  fuel_types: ('diesel' | 'petrol')[];
  duration: number;
  base_price: number;
  tax: number;
  warranty: string;
  guarantee: string;
  badge: string | null;
  features: string[];
  faqs: { question: string; answer: string }[];
  rating?: number;
}

export function dbPlanToApp(dbPlan: DbPlanWithDetails): AppPlanWithDetails {
  return {
    plan_id: dbPlan.id,
    service_id: dbPlan.service_id,
    company_id: dbPlan.company_id,
    name: dbPlan.name,
    service_name: dbPlan.service_name,
    company_name: dbPlan.company_name,
    vehicle_type: dbPlan.vehicle_type,
    location_type: dbPlan.location_type,
    fuel_types: dbPlan.fuel_types as ('diesel' | 'petrol')[],
    duration: dbPlan.duration,
    base_price: dbPlan.base_price,
    tax: dbPlan.tax,
    warranty: dbPlan.warranty,
    guarantee: dbPlan.guarantee,
    badge: dbPlan.badge,
    features: dbPlan.features.map(f => f.feature),
    faqs: dbPlan.faqs.map(f => ({ question: f.question, answer: f.answer })),
    rating: dbPlan.rating,
  };
}

// ===========================================
// Utility Functions
// ===========================================

/**
 * Convert snake_case to camelCase
 */
export function snakeToCamel(str: string): string {
  return str.replace(/_([a-z])/g, (_, letter) => letter.toUpperCase());
}

/**
 * Convert camelCase to snake_case
 */
export function camelToSnake(str: string): string {
  return str.replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`);
}

/**
 * Convert object keys from snake_case to camelCase
 */
export function objectKeysToCamel<T extends Record<string, any>>(obj: T): any {
  if (obj === null || typeof obj !== 'object') return obj;
  
  if (Array.isArray(obj)) {
    return obj.map(item => objectKeysToCamel(item));
  }
  
  return Object.keys(obj).reduce((acc, key) => {
    const camelKey = snakeToCamel(key);
    acc[camelKey] = objectKeysToCamel(obj[key]);
    return acc;
  }, {} as any);
}

/**
 * Convert object keys from camelCase to snake_case
 */
export function objectKeysToSnake<T extends Record<string, any>>(obj: T): any {
  if (obj === null || typeof obj !== 'object') return obj;
  
  if (Array.isArray(obj)) {
    return obj.map(item => objectKeysToSnake(item));
  }
  
  return Object.keys(obj).reduce((acc, key) => {
    const snakeKey = camelToSnake(key);
    acc[snakeKey] = objectKeysToSnake(obj[key]);
    return acc;
  }, {} as any);
}

// ===========================================
// Type Guards
// ===========================================

export function isOrderStatus(status: string): status is OrderStatus {
  return ['pending', 'confirmed', 'in_progress', 'completed', 'cancelled'].includes(status);
}

export function isPaymentMethod(method: string): method is PaymentMethod {
  return ['credit_card', 'debit_card', 'net_banking', 'upi'].includes(method);
}

export function isPaymentStatus(status: string): status is PaymentStatus {
  return ['paid', 'unpaid'].includes(status);
}


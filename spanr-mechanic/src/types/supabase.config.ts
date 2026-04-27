/**
 * Supabase Client Configuration
 * 
 * This file provides typed Supabase client setup and helper functions
 * for interacting with the database.
 */

import { createClient } from '@supabase/supabase-js';

// Database type definitions
export interface Database {
  public: {
    Tables: {
      users: {
        Row: {
          id: string;
          user_id: string;
          email: string;
          name: string;
          phone: string;
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database['public']['Tables']['users']['Row'], 'id' | 'created_at' | 'updated_at'>;
        Update: Partial<Database['public']['Tables']['users']['Insert']>;
      };
      mechanic_companies: {
        Row: {
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
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database['public']['Tables']['mechanic_companies']['Row'], 'id' | 'created_at' | 'updated_at'>;
        Update: Partial<Database['public']['Tables']['mechanic_companies']['Insert']>;
      };
      staff: {
        Row: {
          id: string;
          company_id: string;
          email: string;
          name: string;
          enabled: boolean;
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database['public']['Tables']['staff']['Row'], 'id' | 'created_at' | 'updated_at'>;
        Update: Partial<Database['public']['Tables']['staff']['Insert']>;
      };
      services: {
        Row: {
          id: string;
          company_id: string;
          name: string;
          category: 'car' | 'bike';
          icon_url: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database['public']['Tables']['services']['Row'], 'id' | 'created_at' | 'updated_at'>;
        Update: Partial<Database['public']['Tables']['services']['Insert']>;
      };
      plans: {
        Row: {
          id: string;
          service_id: string;
          company_id: string;
          name: string;
          vehicle_type: 'car' | 'bike';
          location_type: 'in_premise' | 'shed';
          duration: number;
          base_price: number;
          tax: number;
          warranty: string;
          guarantee: string;
          badge: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database['public']['Tables']['plans']['Row'], 'id' | 'created_at' | 'updated_at'>;
        Update: Partial<Database['public']['Tables']['plans']['Insert']>;
      };
      vehicles: {
        Row: {
          id: string;
          user_id: string;
          make: string;
          model: string;
          year: number;
          license_plate: string;
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database['public']['Tables']['vehicles']['Row'], 'id' | 'created_at' | 'updated_at'>;
        Update: Partial<Database['public']['Tables']['vehicles']['Insert']>;
      };
      orders: {
        Row: {
          id: string;
          company_id: string;
          user_id: string;
          plan_id: string;
          vehicle_id: string;
          order_date: string;
          scheduled_service_date: string;
          status: 'pending' | 'confirmed' | 'in_progress' | 'completed' | 'cancelled';
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
        };
        Insert: Omit<Database['public']['Tables']['orders']['Row'], 'id' | 'created_at' | 'updated_at'>;
        Update: Partial<Database['public']['Tables']['orders']['Insert']>;
      };
      payments: {
        Row: {
          id: string;
          order_id: string;
          method: 'credit_card' | 'debit_card' | 'net_banking' | 'upi';
          status: 'paid' | 'unpaid';
          amount: number;
          transaction_id: string | null;
          paid_at: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database['public']['Tables']['payments']['Row'], 'id' | 'created_at' | 'updated_at'>;
        Update: Partial<Database['public']['Tables']['payments']['Insert']>;
      };
    };
    Views: {
      company_profiles: {
        Row: {
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
          ratings_count: number;
          professionalism: number;
          timeliness: number;
          quality: number;
          rating: number;
          certifications: string[];
          specializations: string[];
          services_offered: string[];
          created_at: string;
          updated_at: string;
        };
      };
      order_details: {
        Row: {
          id: string;
          company_id: string;
          user_id: string;
          plan_id: string;
          vehicle_id: string;
          user_name: string;
          user_email: string;
          user_phone: string;
          vehicle_make: string;
          vehicle_model: string;
          vehicle_year: number;
          license_plate: string;
          plan_name: string;
          base_price: number;
          tax: number;
          service_name: string;
          company_name: string;
          payment_status: 'paid' | 'unpaid';
          payment_method: 'credit_card' | 'debit_card' | 'net_banking' | 'upi';
          payment_amount: number;
          order_date: string;
          scheduled_service_date: string;
          status: 'pending' | 'confirmed' | 'in_progress' | 'completed' | 'cancelled';
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
        };
      };
    };
    Functions: {};
    Enums: {
      vehicle_type: 'car' | 'bike';
      fuel_type: 'diesel' | 'petrol';
      location_type: 'in_premise' | 'shed';
      order_status: 'pending' | 'confirmed' | 'in_progress' | 'completed' | 'cancelled';
      payment_method: 'credit_card' | 'debit_card' | 'net_banking' | 'upi';
      payment_status: 'paid' | 'unpaid';
      entity_type: 'company' | 'plan' | 'service' | 'order';
    };
  };
}

/**
 * Create a typed Supabase client
 * 
 * @param supabaseUrl - Your Supabase project URL
 * @param supabaseKey - Your Supabase anon/public key
 * @returns Typed Supabase client
 */
export function createSupabaseClient(supabaseUrl: string, supabaseKey: string) {
  return createClient<Database>(supabaseUrl, supabaseKey);
}

/**
 * Type-safe query builder helpers
 */
export type SupabaseClient = ReturnType<typeof createSupabaseClient>;

// Example usage:
// const supabase = createSupabaseClient(
//   process.env.REACT_APP_SUPABASE_URL!,
//   process.env.REACT_APP_SUPABASE_ANON_KEY!
// );
//
// // All queries are now fully typed!
// const { data, error } = await supabase
//   .from('mechanic_companies')
//   .select('*')
//   .eq('city', 'Mumbai');


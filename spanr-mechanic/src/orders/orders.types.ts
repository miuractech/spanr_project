import type { DbOrder } from '../types';

export interface OrderUser {
  name: string;
  email: string;
  phone: string;
}

export interface OrderVehicle {
  make: string;
  model: string;
  year: number;
  license_plate: string;
}

export interface OrderPlan {
  name: string;
  base_price: number;
  tax: number;
  vehicle_type?: 'car' | 'bike';
}

export interface OrderService {
  name: string;
}

export interface OrderPayment {
  status: 'paid' | 'unpaid';
  method: string;
  amount: number;
}

export interface OrderDetails extends DbOrder {
  user: OrderUser;
  vehicle: OrderVehicle;
  plan: OrderPlan;
  service: OrderService;
  payment?: OrderPayment;
}

export type OrderStatus = 
  | 'created' 
  | 'accepted' 
  | 'in_progress' 
  | 'ready_for_delivery' 
  | 'completed' 
  | 'dispute' 
  | 'cancelled';

export interface OrderFilters {
  status?: OrderStatus;
  startDate?: Date;
  endDate?: Date;
  search?: string;
}

export interface PaginatedOrders {
  data: OrderDetails[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

export interface OrderImage {
  id: string;
  order_id: string;
  image_url: string;
  uploaded_by?: string;
  created_at: string;
}

export interface OrderServiceDetail {
  id: string;
  order_id: string;
  description: string;
  parts_used?: string;
  labor_hours?: number;
  additional_charges?: number;
  notes?: string;
  created_at: string;
  updated_at: string;
}

export interface OrderHistory {
  id: string;
  order_id: string;
  status: OrderStatus;
  notes?: string;
  changed_by?: string;
  created_at: string;
}


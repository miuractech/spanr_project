export interface VehicleServiceRecord {
  id: string;
  order_id?: string;
  vehicle_id?: string;
  company_id?: string;
  staff_id?: string;
  customer_id?: string;
  vehicle_make?: string;
  vehicle_model?: string;
  vehicle_year?: number;
  license_plate?: string;
  customer_name?: string;
  mechanic_name?: string;
  company_name?: string;
  service_date: string;
  odometer_reading?: number;
  services_performed?: string;
  service_notes?: string;
  created_at: string;
}

export interface PartReplaced {
  id: string;
  order_id?: string;
  service_history_id?: string;
  part_name: string;
  part_number?: string;
  brand?: string;
  quantity: number;
  cost?: number;
  photo_url?: string;
  km_reading?: number;
  replacement_date: string;
}

export interface InspectionImage {
  id: string;
  order_id: string;
  service_history_id?: string;
  type: 'before' | 'after';
  angle: 'front' | 'back' | 'left' | 'right' | 'other';
  image_url: string;
  created_at: string;
}

export interface ServiceRecordDetail extends VehicleServiceRecord {
  parts: PartReplaced[];
  inspection_images: InspectionImage[];
}

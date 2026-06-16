import supabase from '../supabaseconfig';
import type { ServiceRecordDetail, VehicleServiceRecord } from './vehicle_history.types';

export const vehicleHistoryService = {
  async getHistoryByCompany(companyId: string): Promise<VehicleServiceRecord[]> {
    const { data, error } = await supabase
      .from('vehicle_service_history')
      .select('*')
      .eq('company_id', companyId)
      .order('service_date', { ascending: false });

    if (error) throw error;
    return data ?? [];
  },

  async searchByPlate(companyId: string, plate: string): Promise<VehicleServiceRecord[]> {
    const { data, error } = await supabase
      .from('vehicle_service_history')
      .select('*')
      .eq('company_id', companyId)
      .ilike('license_plate', `%${plate}%`)
      .order('service_date', { ascending: false });

    if (error) throw error;
    return data ?? [];
  },

  async getHistoryByOrder(orderId: string): Promise<VehicleServiceRecord | null> {
    const { data, error } = await supabase
      .from('vehicle_service_history')
      .select('*')
      .eq('order_id', orderId)
      .maybeSingle();

    if (error) throw error;
    return data;
  },

  async getServiceRecord(id: string): Promise<ServiceRecordDetail | null> {
    const { data: record, error } = await supabase
      .from('vehicle_service_history')
      .select('*')
      .eq('id', id)
      .maybeSingle();

    if (error) throw error;
    if (!record) return null;

    const [partsRes, imagesRes] = await Promise.all([
      supabase.from('parts_replaced').select('*').eq('service_history_id', id),
      supabase.from('inspection_images').select('*').eq('service_history_id', id),
    ]);

    return {
      ...record,
      parts: partsRes.data ?? [],
      inspection_images: imagesRes.data ?? [],
    };
  },
};

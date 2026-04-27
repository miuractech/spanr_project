import supabase from '../supabaseconfig';
import type { DbService } from '../types';

export interface ServiceFormData {
  name: string;
  description?: string;
  category: 'car' | 'bike';
  iconUrl?: string;
}

export const servicesService = {
  async getServicesByCompany(companyId: string): Promise<DbService[]> {
    const { data, error } = await supabase
      .from('services')
      .select('*')
      .eq('company_id', companyId)
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data || [];
  },

  async createService(companyId: string, data: ServiceFormData): Promise<DbService> {
    const { data: service, error } = await supabase
      .from('services')
      .insert({
        company_id: companyId,
        name: data.name,
        description: data.description,
        category: data.category,
        icon_url: data.iconUrl,
      })
      .select()
      .single();

    if (error) throw error;
    return service;
  },

  async updateService(serviceId: string, data: Partial<ServiceFormData>): Promise<DbService> {
    const { data: service, error } = await supabase
      .from('services')
      .update({
        name: data.name,
        description: data.description,
        category: data.category,
        icon_url: data.iconUrl,
      })
      .eq('id', serviceId)
      .select()
      .single();

    if (error) throw error;
    return service;
  },

  async deleteService(serviceId: string): Promise<void> {
    const { error } = await supabase
      .from('services')
      .delete()
      .eq('id', serviceId);

    if (error) throw error;
  },

  async uploadIcon(file: File, serviceId: string): Promise<string> {
    const fileExt = file.name.split('.').pop();
    const fileName = `${serviceId}-${Date.now()}.${fileExt}`;
    const filePath = `${fileName}`;

    const { error: uploadError } = await supabase.storage
      .from('service-icons')
      .upload(filePath, file, { upsert: true });

    if (uploadError) throw uploadError;

    const { data } = supabase.storage
      .from('service-icons')
      .getPublicUrl(filePath);

    return data.publicUrl;
  },
};


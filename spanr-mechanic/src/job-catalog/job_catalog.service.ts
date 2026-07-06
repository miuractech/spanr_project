import supabase from '../supabaseconfig';
import type { JobSection, JobCatalogItem, VehicleType } from './job_catalog.types';

function mapSection(r: Record<string, unknown>): JobSection {
  return {
    id: r.id as string,
    companyId: r.company_id as string,
    vehicleType: r.vehicle_type as VehicleType,
    name: r.name as string,
    imageUrl: r.image_url as string | null,
    displayOrder: Number(r.display_order),
  };
}

function mapJob(r: Record<string, unknown>): JobCatalogItem {
  return {
    id: r.id as string,
    companyId: r.company_id as string,
    sectionId: r.section_id as string,
    name: r.name as string,
    thumbnailUrl: r.thumbnail_url as string | null,
    basePrice: Number(r.base_price),
    displayOrder: Number(r.display_order),
    isActive: Boolean(r.is_active),
  };
}

export const jobCatalogService = {
  async getSections(companyId: string, vehicleType?: VehicleType): Promise<JobSection[]> {
    let q = supabase
      .from('job_sections')
      .select('*')
      .eq('company_id', companyId)
      .order('display_order');
    if (vehicleType) q = q.eq('vehicle_type', vehicleType);
    const { data, error } = await q;
    if (error) throw error;
    return (data ?? []).map((r) => mapSection(r as Record<string, unknown>));
  },

  async createSection(
    companyId: string,
    data: {
      name: string;
      vehicleType: VehicleType;
      imageUrl?: string;
      displayOrder?: number;
    }
  ): Promise<JobSection> {
    const { data: row, error } = await supabase
      .from('job_sections')
      .insert({
        company_id: companyId,
        vehicle_type: data.vehicleType,
        name: data.name,
        image_url: data.imageUrl ?? null,
        display_order: data.displayOrder ?? 0,
      })
      .select()
      .single();
    if (error) throw error;
    return mapSection(row as Record<string, unknown>);
  },

  async updateSection(
    id: string,
    data: Partial<{ name: string; imageUrl: string; displayOrder: number }>
  ): Promise<void> {
    const { error } = await supabase
      .from('job_sections')
      .update({
        name: data.name,
        image_url: data.imageUrl,
        display_order: data.displayOrder,
      })
      .eq('id', id);
    if (error) throw error;
  },

  async deleteSection(id: string): Promise<void> {
    const { error } = await supabase.from('job_sections').delete().eq('id', id);
    if (error) throw error;
  },

  async getJobs(companyId: string, sectionId?: string): Promise<JobCatalogItem[]> {
    let q = supabase
      .from('job_catalog')
      .select('*')
      .eq('company_id', companyId)
      .order('display_order');
    if (sectionId) q = q.eq('section_id', sectionId);
    const { data, error } = await q;
    if (error) throw error;
    return (data ?? []).map((r) => mapJob(r as Record<string, unknown>));
  },

  async createJob(data: {
    companyId: string;
    sectionId: string;
    name: string;
    basePrice: number;
    thumbnailUrl?: string;
    displayOrder?: number;
  }): Promise<JobCatalogItem> {
    const { data: row, error } = await supabase
      .from('job_catalog')
      .insert({
        company_id: data.companyId,
        section_id: data.sectionId,
        name: data.name,
        base_price: data.basePrice,
        thumbnail_url: data.thumbnailUrl ?? null,
        display_order: data.displayOrder ?? 0,
      })
      .select()
      .single();
    if (error) throw error;
    return mapJob(row as Record<string, unknown>);
  },

  async updateJob(
    id: string,
    data: Partial<{
      name: string;
      basePrice: number;
      thumbnailUrl: string;
      displayOrder: number;
      isActive: boolean;
    }>
  ): Promise<void> {
    const { error } = await supabase
      .from('job_catalog')
      .update({
        name: data.name,
        base_price: data.basePrice,
        thumbnail_url: data.thumbnailUrl,
        display_order: data.displayOrder,
        is_active: data.isActive,
      })
      .eq('id', id);
    if (error) throw error;
  },

  async deleteJob(id: string): Promise<void> {
    const { error } = await supabase.from('job_catalog').delete().eq('id', id);
    if (error) throw error;
  },

  async uploadSectionImage(file: File, sectionId: string): Promise<string> {
    const ext = file.name.split('.').pop();
    const path = `sections/${sectionId}-${Date.now()}.${ext}`;
    const { error } = await supabase.storage
      .from('service-icons')
      .upload(path, file, { upsert: true });
    if (error) throw error;
    return supabase.storage.from('service-icons').getPublicUrl(path).data.publicUrl;
  },

  async uploadJobThumbnail(file: File, jobId: string): Promise<string> {
    const ext = file.name.split('.').pop();
    const path = `jobs/${jobId}-${Date.now()}.${ext}`;
    const { error } = await supabase.storage
      .from('service-icons')
      .upload(path, file, { upsert: true });
    if (error) throw error;
    return supabase.storage.from('service-icons').getPublicUrl(path).data.publicUrl;
  },

  async getIncludedJobs(planId: string): Promise<string[]> {
    const { data, error } = await supabase
      .from('plan_included_jobs')
      .select('job_id')
      .eq('plan_id', planId);
    if (error) throw error;
    return (data ?? []).map((r) => r.job_id as string);
  },

  async setIncludedJobs(planId: string, jobIds: string[]): Promise<void> {
    await supabase.from('plan_included_jobs').delete().eq('plan_id', planId);
    if (jobIds.length === 0) return;
    const { error } = await supabase
      .from('plan_included_jobs')
      .insert(jobIds.map((jobId) => ({ plan_id: planId, job_id: jobId })));
    if (error) throw error;
  },
};

import supabase from '../supabaseconfig';
import type { DbPlan } from '../types';

export interface PlanFormData {
  serviceId: string;
  name: string;
  vehicleType: 'car' | 'bike';
  locationType: 'in_premise' | 'shed';
  duration: number;
  basePrice: number;
  tax: number;
  warranty?: string;
  guarantee?: string;
  badge?: string;
  fuelTypes: ('diesel' | 'petrol')[];
  features: { feature: string; displayOrder: number }[];
  faqs: { question: string; answer: string; displayOrder: number }[];
  serviceOutcomes: { title: string; imageUrl: string; description: string; displayOrder: number }[];
  additionalServices: { serviceName: string; displayOrder: number }[];
  steps: { stepDescription: string; displayOrder: number }[];
}

export interface PlanDetails extends DbPlan {
  fuelTypes: string[];
  features: Array<{ id: string; feature: string; display_order: number }>;
  faqs: Array<{ id: string; question: string; answer: string; display_order: number }>;
  serviceOutcomes: Array<{ id: string; title: string; image_url: string; description: string; display_order: number }>;
  additionalServices: Array<{ id: string; service_name: string; display_order: number }>;
  steps: Array<{ id: string; step_description: string; display_order: number }>;
}

export const plansService = {
  async getPlansByCompany(companyId: string): Promise<DbPlan[]> {
    const { data, error } = await supabase
      .from('plans')
      .select('*, services(name)')
      .eq('company_id', companyId)
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data || [];
  },

  async getPlansByService(serviceId: string): Promise<DbPlan[]> {
    const { data, error } = await supabase
      .from('plans')
      .select('*')
      .eq('service_id', serviceId)
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data || [];
  },

  async getPlanDetails(planId: string): Promise<PlanDetails | null> {
    const { data: plan, error: planError } = await supabase
      .from('plans')
      .select('*')
      .eq('id', planId)
      .single();

    if (planError) throw planError;

    const [fuelTypes, features, faqs, outcomes, additionalServices, steps] = await Promise.all([
      this.getPlanFuelTypes(planId),
      this.getPlanFeatures(planId),
      this.getPlanFaqs(planId),
      this.getPlanOutcomes(planId),
      this.getPlanAdditionalServices(planId),
      this.getPlanSteps(planId),
    ]);

    return {
      ...plan,
      fuelTypes,
      features,
      faqs,
      serviceOutcomes: outcomes,
      additionalServices,
      steps,
    };
  },

  async createPlan(companyId: string, data: PlanFormData): Promise<DbPlan> {
    const { data: plan, error } = await supabase
      .from('plans')
      .insert({
        service_id: data.serviceId,
        company_id: companyId,
        name: data.name,
        vehicle_type: data.vehicleType,
        location_type: data.locationType,
        duration: data.duration,
        base_price: data.basePrice,
        tax: data.tax,
        warranty: data.warranty,
        guarantee: data.guarantee,
        badge: data.badge,
      })
      .select()
      .single();

    if (error) throw error;

    // Add related data
    await Promise.all([
      this.addPlanFuelTypes(plan.id, data.fuelTypes),
      this.addPlanFeatures(plan.id, data.features),
      this.addPlanFaqs(plan.id, data.faqs),
      this.addPlanServiceOutcomes(plan.id, data.serviceOutcomes),
      this.addPlanAdditionalServices(plan.id, data.additionalServices),
      this.addPlanSteps(plan.id, data.steps),
    ]);

    return plan;
  },

  async updatePlan(planId: string, data: Partial<PlanFormData>): Promise<DbPlan> {
    const { data: plan, error } = await supabase
      .from('plans')
      .update({
        service_id: data.serviceId,
        name: data.name,
        vehicle_type: data.vehicleType,
        location_type: data.locationType,
        duration: data.duration,
        base_price: data.basePrice,
        tax: data.tax,
        warranty: data.warranty,
        guarantee: data.guarantee,
        badge: data.badge,
      })
      .eq('id', planId)
      .select()
      .single();

    if (error) throw error;

    // Update related data if provided
    if (data.fuelTypes) {
      await this.updatePlanFuelTypes(planId, data.fuelTypes);
    }
    if (data.features) {
      await this.updatePlanFeatures(planId, data.features);
    }
    if (data.faqs) {
      await this.updatePlanFaqs(planId, data.faqs);
    }
    if (data.serviceOutcomes) {
      await this.updatePlanServiceOutcomes(planId, data.serviceOutcomes);
    }
    if (data.additionalServices) {
      await this.updatePlanAdditionalServices(planId, data.additionalServices);
    }
    if (data.steps) {
      await this.updatePlanSteps(planId, data.steps);
    }

    return plan;
  },

  async deletePlan(planId: string): Promise<void> {
    const { error } = await supabase
      .from('plans')
      .delete()
      .eq('id', planId);

    if (error) throw error;
  },

  async uploadOutcomeImage(file: File, planId: string): Promise<string> {
    const fileExt = file.name.split('.').pop();
    const fileName = `${planId}-${Date.now()}.${fileExt}`;

    const { error: uploadError } = await supabase.storage
      .from('plan-images')
      .upload(fileName, file, { upsert: true });

    if (uploadError) throw uploadError;

    const { data } = supabase.storage
      .from('plan-images')
      .getPublicUrl(fileName);

    return data.publicUrl;
  },

  // Fuel Types
  async getPlanFuelTypes(planId: string): Promise<string[]> {
    const { data, error } = await supabase
      .from('plan_fuel_types')
      .select('fuel_type')
      .eq('plan_id', planId);

    if (error) throw error;
    return data?.map(d => d.fuel_type) || [];
  },

  async addPlanFuelTypes(planId: string, fuelTypes: string[]): Promise<void> {
    if (fuelTypes.length === 0) return;

    const { error } = await supabase
      .from('plan_fuel_types')
      .insert(fuelTypes.map(ft => ({ plan_id: planId, fuel_type: ft })));

    if (error) throw error;
  },

  async updatePlanFuelTypes(planId: string, fuelTypes: string[]): Promise<void> {
    // Delete existing
    await supabase.from('plan_fuel_types').delete().eq('plan_id', planId);
    // Add new
    await this.addPlanFuelTypes(planId, fuelTypes);
  },

  // Features
  async getPlanFeatures(planId: string) {
    const { data, error } = await supabase
      .from('plan_features')
      .select('*')
      .eq('plan_id', planId)
      .order('display_order');

    if (error) throw error;
    return data || [];
  },

  async addPlanFeatures(planId: string, features: { feature: string; displayOrder: number }[]): Promise<void> {
    if (features.length === 0) return;

    const { error } = await supabase
      .from('plan_features')
      .insert(features.map(f => ({ plan_id: planId, feature: f.feature, display_order: f.displayOrder })));

    if (error) throw error;
  },

  async updatePlanFeatures(planId: string, features: { feature: string; displayOrder: number }[]): Promise<void> {
    await supabase.from('plan_features').delete().eq('plan_id', planId);
    await this.addPlanFeatures(planId, features);
  },

  // FAQs
  async getPlanFaqs(planId: string) {
    const { data, error } = await supabase
      .from('plan_faqs')
      .select('*')
      .eq('plan_id', planId)
      .order('display_order');

    if (error) throw error;
    return data || [];
  },

  async addPlanFaqs(planId: string, faqs: { question: string; answer: string; displayOrder: number }[]): Promise<void> {
    if (faqs.length === 0) return;

    const { error } = await supabase
      .from('plan_faqs')
      .insert(faqs.map(f => ({ 
        plan_id: planId, 
        question: f.question, 
        answer: f.answer, 
        display_order: f.displayOrder 
      })));

    if (error) throw error;
  },

  async updatePlanFaqs(planId: string, faqs: { question: string; answer: string; displayOrder: number }[]): Promise<void> {
    await supabase.from('plan_faqs').delete().eq('plan_id', planId);
    await this.addPlanFaqs(planId, faqs);
  },

  // Service Outcomes
  async getPlanOutcomes(planId: string) {
    const { data, error } = await supabase
      .from('plan_service_outcomes')
      .select('*')
      .eq('plan_id', planId)
      .order('display_order');

    if (error) throw error;
    return data || [];
  },

  async addPlanServiceOutcomes(planId: string, outcomes: { title: string; imageUrl: string; description: string; displayOrder: number }[]): Promise<void> {
    if (outcomes.length === 0) return;

    const { error } = await supabase
      .from('plan_service_outcomes')
      .insert(outcomes.map(o => ({ 
        plan_id: planId, 
        title: o.title, 
        image_url: o.imageUrl, 
        description: o.description, 
        display_order: o.displayOrder 
      })));

    if (error) throw error;
  },

  async updatePlanServiceOutcomes(planId: string, outcomes: { title: string; imageUrl: string; description: string; displayOrder: number }[]): Promise<void> {
    await supabase.from('plan_service_outcomes').delete().eq('plan_id', planId);
    await this.addPlanServiceOutcomes(planId, outcomes);
  },

  // Additional Services
  async getPlanAdditionalServices(planId: string) {
    const { data, error } = await supabase
      .from('plan_additional_services')
      .select('*')
      .eq('plan_id', planId)
      .order('display_order');

    if (error) throw error;
    return data || [];
  },

  async addPlanAdditionalServices(planId: string, services: { serviceName: string; displayOrder: number }[]): Promise<void> {
    if (services.length === 0) return;

    const { error } = await supabase
      .from('plan_additional_services')
      .insert(services.map(s => ({ 
        plan_id: planId, 
        service_name: s.serviceName, 
        display_order: s.displayOrder 
      })));

    if (error) throw error;
  },

  async updatePlanAdditionalServices(planId: string, services: { serviceName: string; displayOrder: number }[]): Promise<void> {
    await supabase.from('plan_additional_services').delete().eq('plan_id', planId);
    await this.addPlanAdditionalServices(planId, services);
  },

  // Steps
  async getPlanSteps(planId: string) {
    const { data, error } = await supabase
      .from('plan_steps')
      .select('*')
      .eq('plan_id', planId)
      .order('display_order');

    if (error) throw error;
    return data || [];
  },

  async addPlanSteps(planId: string, steps: { stepDescription: string; displayOrder: number }[]): Promise<void> {
    if (steps.length === 0) return;

    const { error } = await supabase
      .from('plan_steps')
      .insert(steps.map(s => ({ 
        plan_id: planId, 
        step_description: s.stepDescription, 
        display_order: s.displayOrder 
      })));

    if (error) throw error;
  },

  async updatePlanSteps(planId: string, steps: { stepDescription: string; displayOrder: number }[]): Promise<void> {
    await supabase.from('plan_steps').delete().eq('plan_id', planId);
    await this.addPlanSteps(planId, steps);
  },
};


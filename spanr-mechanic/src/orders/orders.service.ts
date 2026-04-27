import supabase from '../supabaseconfig';
import type { 
  OrderDetails, 
  OrderFilters, 
  PaginatedOrders, 
  OrderStatus,
  OrderImage,
  OrderServiceDetail,
  OrderHistory
} from './orders.types';

export const ordersService = {
  async getOrdersByCompany(
    companyId: string,
    page: number = 1,
    pageSize: number = 10,
    filters?: OrderFilters
  ): Promise<PaginatedOrders> {
    const from = (page - 1) * pageSize;
    const to = from + pageSize - 1;

    let query = supabase
      .from('orders')
      .select('*', { count: 'exact' })
      .eq('company_id', companyId);

    // Apply search filter - only on order fields
    if (filters?.search) {
      const searchTerm = filters.search.toLowerCase();
      query = query.or(
        `contact_email.ilike.%${searchTerm}%,` +
        `contact_phone.ilike.%${searchTerm}%,` +
        `contact_name.ilike.%${searchTerm}%`
      );
    }

    // Apply status filter
    if (filters?.status) {
      query = query.eq('status', filters.status);
    }

    // Apply date range filters
    if (filters?.startDate) {
      query = query.gte('scheduled_service_date', filters.startDate.toISOString());
    }

    if (filters?.endDate) {
      query = query.lte('scheduled_service_date', filters.endDate.toISOString());
    }

    // Apply pagination and ordering
    query = query
      .order('created_at', { ascending: false })
      .range(from, to);

    const { data: ordersData, error: ordersError, count } = await query;

    if (ordersError) throw ordersError;
    if (!ordersData) {
      return {
        data: [],
        total: 0,
        page,
        pageSize,
        totalPages: 0,
      };
    }

    // Fetch related data separately
    const orders: OrderDetails[] = await Promise.all(
      ordersData.map(async (order) => {
        const [userRes, vehicleRes, planRes, paymentRes] = await Promise.all([
          supabase.from('users').select('name, email, phone').eq('id', order.user_id).single(),
          supabase.from('vehicles').select('make, model, year, license_plate').eq('id', order.vehicle_id).single(),
          supabase.from('plans').select('name, base_price, tax, service_id, vehicle_type').eq('id', order.plan_id).single(),
          supabase.from('payments').select('status, method, amount').eq('order_id', order.id).maybeSingle(),
        ]);

        let serviceName = '';
        if (planRes.data?.service_id) {
          const serviceRes = await supabase
            .from('services')
            .select('name')
            .eq('id', planRes.data.service_id)
            .single();
          serviceName = serviceRes.data?.name || '';
        }

        return {
          ...order,
          user: userRes.data || { name: '', email: '', phone: '' },
          vehicle: vehicleRes.data || { make: '', model: '', year: 0, license_plate: '' },
          plan: planRes.data || { name: '', base_price: 0, tax: 0 },
          service: { name: serviceName },
          payment: paymentRes.data || undefined,
        };
      })
    );

    return {
      data: orders,
      total: count || 0,
      page,
      pageSize,
      totalPages: Math.ceil((count || 0) / pageSize),
    };
  },

  async getOrderById(orderId: string): Promise<OrderDetails | null> {
    const { data: order, error } = await supabase
      .from('orders')
      .select('*')
      .eq('id', orderId)
      .single();

    if (error) throw error;
    if (!order) return null;

    // Fetch related data separately
    const [userRes, vehicleRes, planRes, paymentRes] = await Promise.all([
      supabase.from('users').select('name, email, phone').eq('id', order.user_id).single(),
      supabase.from('vehicles').select('make, model, year, license_plate').eq('id', order.vehicle_id).single(),
      supabase.from('plans').select('name, base_price, tax, service_id, vehicle_type').eq('id', order.plan_id).single(),
      supabase.from('payments').select('status, method, amount').eq('order_id', order.id).maybeSingle(),
    ]);

    let serviceName = '';
    if (planRes.data?.service_id) {
      const serviceRes = await supabase
        .from('services')
        .select('name')
        .eq('id', planRes.data.service_id)
        .single();
      serviceName = serviceRes.data?.name || '';
    }

    return {
      ...order,
      user: userRes.data || { name: '', email: '', phone: '' },
      vehicle: vehicleRes.data || { make: '', model: '', year: 0, license_plate: '' },
      plan: planRes.data || { name: '', base_price: 0, tax: 0 },
      service: { name: serviceName },
      payment: paymentRes.data || undefined,
    };
  },

  async updateOrderStatus(
    orderId: string,
    status: OrderStatus,
    notes?: string
  ): Promise<void> {
    const { error } = await supabase
      .from('orders')
      .update({ status })
      .eq('id', orderId);

    if (error) throw error;

    // Add to history if notes provided
    if (notes) {
      await supabase
        .from('order_history')
        .insert({
          order_id: orderId,
          status,
          notes,
        });
    }
  },

  async getOrderStats(companyId: string) {
    const { data, error } = await supabase
      .from('orders')
      .select('status')
      .eq('company_id', companyId);

    if (error) throw error;

    const stats = {
      total: data?.length || 0,
      created: data?.filter(o => o.status === 'created').length || 0,
      accepted: data?.filter(o => o.status === 'accepted').length || 0,
      inProgress: data?.filter(o => o.status === 'in_progress').length || 0,
      readyForDelivery: data?.filter(o => o.status === 'ready_for_delivery').length || 0,
      completed: data?.filter(o => o.status === 'completed').length || 0,
      dispute: data?.filter(o => o.status === 'dispute').length || 0,
      cancelled: data?.filter(o => o.status === 'cancelled').length || 0,
    };

    return stats;
  },

  // Image management
  async getOrderAfterImages(orderId: string): Promise<OrderImage[]> {
    const { data, error } = await supabase
      .from('order_after_images')
      .select('*')
      .eq('order_id', orderId)
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data || [];
  },

  async getOrderBeforeImages(orderId: string): Promise<OrderImage[]> {
    const { data, error } = await supabase
      .from('order_before_images')
      .select('*')
      .eq('order_id', orderId)
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data || [];
  },

  async uploadAfterImage(orderId: string, file: File): Promise<string> {
    const fileExt = file.name.split('.').pop();
    const fileName = `${orderId}/${Date.now()}.${fileExt}`;
    
    const { error: uploadError } = await supabase.storage
      .from('orders')
      .upload(fileName, file);

    if (uploadError) throw uploadError;

    const { data: { publicUrl } } = supabase.storage
      .from('orders')
      .getPublicUrl(fileName);

    const { error: dbError } = await supabase
      .from('order_after_images')
      .insert({
        order_id: orderId,
        image_url: publicUrl,
      });

    if (dbError) throw dbError;

    return publicUrl;
  },

  async deleteAfterImage(imageId: string): Promise<void> {
    const { error } = await supabase
      .from('order_after_images')
      .delete()
      .eq('id', imageId);

    if (error) throw error;
  },

  // Service details
  async getOrderServiceDetails(orderId: string): Promise<OrderServiceDetail | null> {
    const { data, error } = await supabase
      .from('order_service_details')
      .select('*')
      .eq('order_id', orderId)
      .single();

    if (error && error.code !== 'PGRST116') throw error;
    return data;
  },

  async upsertOrderServiceDetails(
    orderId: string,
    details: Partial<OrderServiceDetail>
  ): Promise<void> {
    const { error } = await supabase
      .from('order_service_details')
      .upsert({
        order_id: orderId,
        ...details,
      });

    if (error) throw error;
  },

  // Job card data
  async getJobCardData(orderId: string): Promise<Record<string, unknown> | null> {
    const { data, error } = await supabase
      .from('order_service_details')
      .select('job_card_data')
      .eq('order_id', orderId)
      .maybeSingle();

    if (error && error.code !== 'PGRST116') throw error;
    return (data?.job_card_data as Record<string, unknown>) ?? null;
  },

  async saveJobCardData(orderId: string, jobCardData: Record<string, unknown>): Promise<void> {
    const { error } = await supabase
      .from('order_service_details')
      .upsert({ order_id: orderId, job_card_data: jobCardData });

    if (error) throw error;
  },

  // Order history
  async getOrderHistory(orderId: string): Promise<OrderHistory[]> {
    const { data, error } = await supabase
      .from('order_history')
      .select('*')
      .eq('order_id', orderId)
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data || [];
  },
};


/**
 * Example React Hooks for Supabase Queries
 * 
 * These are example hooks showing how to use Supabase with React.
 * Copy and adapt these to your needs.
 */

import { useState, useEffect } from 'react';
import { supabase } from '../src/lib/supabase'; // Adjust path as needed
import type {
  DbMechanicCompany,
  DbOrder,
  DbPlan,
  OrderStatus,
} from '../types';

// ===========================================
// Generic Hook Pattern
// ===========================================

interface UseSupabaseQueryResult<T> {
  data: T | null;
  loading: boolean;
  error: Error | null;
  refetch: () => Promise<void>;
}

function useSupabaseQuery<T>(
  queryFn: () => Promise<{ data: T | null; error: any }>,
  dependencies: any[] = []
): UseSupabaseQueryResult<T> {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  const fetchData = async () => {
    try {
      setLoading(true);
      setError(null);
      const { data: result, error: queryError } = await queryFn();
      
      if (queryError) throw new Error(queryError.message);
      setData(result);
    } catch (err) {
      setError(err as Error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, dependencies);

  return { data, loading, error, refetch: fetchData };
}

// ===========================================
// Company Hooks
// ===========================================

export function useCompanies(city?: string) {
  return useSupabaseQuery<DbMechanicCompany[]>(async () => {
    let query = supabase.from('mechanic_companies').select('*');
    
    if (city) {
      query = query.ilike('city', `%${city}%`);
    }
    
    return query;
  }, [city]);
}

export function useCompany(companyId: string) {
  return useSupabaseQuery<any>(async () => {
    return supabase
      .from('company_profiles')
      .select('*')
      .eq('id', companyId)
      .single();
  }, [companyId]);
}

export function useCompanyPlans(companyId: string) {
  return useSupabaseQuery<DbPlan[]>(async () => {
    return supabase
      .from('plans')
      .select('*')
      .eq('company_id', companyId);
  }, [companyId]);
}

// ===========================================
// Plan Hooks
// ===========================================

export function usePlans(filters?: {
  vehicleType?: 'car' | 'bike';
  city?: string;
  minPrice?: number;
  maxPrice?: number;
}) {
  return useSupabaseQuery<any[]>(async () => {
    let query = supabase
      .from('plans')
      .select(`
        *,
        services!inner (
          name,
          category
        ),
        mechanic_companies!inner (
          company_name,
          city
        )
      `);

    if (filters?.vehicleType) {
      query = query.eq('vehicle_type', filters.vehicleType);
    }

    if (filters?.city) {
      query = query.ilike('mechanic_companies.city', `%${filters.city}%`);
    }

    if (filters?.minPrice) {
      query = query.gte('base_price', filters.minPrice);
    }

    if (filters?.maxPrice) {
      query = query.lte('base_price', filters.maxPrice);
    }

    return query;
  }, [filters?.vehicleType, filters?.city, filters?.minPrice, filters?.maxPrice]);
}

export function usePlan(planId: string) {
  return useSupabaseQuery<any>(async () => {
    // Get plan with all related data
    const [planResult, featuresResult, faqsResult, fuelTypesResult] = await Promise.all([
      supabase.from('plans').select('*, services(*), mechanic_companies(*)').eq('id', planId).single(),
      supabase.from('plan_features').select('*').eq('plan_id', planId).order('display_order'),
      supabase.from('plan_faqs').select('*').eq('plan_id', planId).order('display_order'),
      supabase.from('plan_fuel_types').select('*').eq('plan_id', planId),
    ]);

    if (planResult.error) return { data: null, error: planResult.error };

    return {
      data: {
        ...planResult.data,
        features: featuresResult.data || [],
        faqs: faqsResult.data || [],
        fuel_types: fuelTypesResult.data?.map(ft => ft.fuel_type) || [],
      },
      error: null,
    };
  }, [planId]);
}

// ===========================================
// Order Hooks
// ===========================================

export function useUserOrders(userId: string) {
  return useSupabaseQuery<any[]>(async () => {
    return supabase
      .from('order_details')
      .select('*')
      .eq('user_id', userId)
      .order('order_date', { ascending: false });
  }, [userId]);
}

export function useCompanyOrders(companyId: string, status?: OrderStatus) {
  return useSupabaseQuery<any[]>(async () => {
    let query = supabase
      .from('order_details')
      .select('*')
      .eq('company_id', companyId);

    if (status) {
      query = query.eq('status', status);
    }

    return query.order('scheduled_service_date', { ascending: true });
  }, [companyId, status]);
}

export function useOrder(orderId: string) {
  return useSupabaseQuery<any>(async () => {
    return supabase
      .from('order_details')
      .select('*')
      .eq('id', orderId)
      .single();
  }, [orderId]);
}

// ===========================================
// Mutation Hooks
// ===========================================

interface UseSupabaseMutationResult<TInput, TOutput> {
  mutate: (input: TInput) => Promise<TOutput>;
  loading: boolean;
  error: Error | null;
}

function useSupabaseMutation<TInput, TOutput>(
  mutationFn: (input: TInput) => Promise<{ data: TOutput | null; error: any }>
): UseSupabaseMutationResult<TInput, TOutput> {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  const mutate = async (input: TInput): Promise<TOutput> => {
    try {
      setLoading(true);
      setError(null);
      
      const { data, error: mutationError } = await mutationFn(input);
      
      if (mutationError) throw new Error(mutationError.message);
      if (!data) throw new Error('No data returned');
      
      return data;
    } catch (err) {
      const error = err as Error;
      setError(error);
      throw error;
    } finally {
      setLoading(false);
    }
  };

  return { mutate, loading, error };
}

export function useCreateOrder() {
  return useSupabaseMutation(async (orderData: any) => {
    return supabase
      .from('orders')
      .insert(orderData)
      .select()
      .single();
  });
}

export function useUpdateOrderStatus() {
  return useSupabaseMutation(async ({ orderId, status }: { orderId: string; status: OrderStatus }) => {
    return supabase
      .from('orders')
      .update({ status })
      .eq('id', orderId)
      .select()
      .single();
  });
}

export function useCreateVehicle() {
  return useSupabaseMutation(async (vehicleData: any) => {
    return supabase
      .from('vehicles')
      .insert(vehicleData)
      .select()
      .single();
  });
}

export function useUpdatePaymentStatus() {
  return useSupabaseMutation(async ({
    orderId,
    status,
    transactionId,
  }: {
    orderId: string;
    status: 'paid' | 'unpaid';
    transactionId?: string;
  }) => {
    return supabase
      .from('payments')
      .update({
        status,
        transaction_id: transactionId,
        paid_at: status === 'paid' ? new Date().toISOString() : null,
      })
      .eq('order_id', orderId)
      .select()
      .single();
  });
}

// ===========================================
// Real-time Hooks
// ===========================================

export function useRealtimeOrders(companyId: string) {
  const [orders, setOrders] = useState<any[]>([]);

  useEffect(() => {
    // Initial fetch
    supabase
      .from('order_details')
      .select('*')
      .eq('company_id', companyId)
      .then(({ data }) => {
        if (data) setOrders(data);
      });

    // Subscribe to changes
    const subscription = supabase
      .channel(`company-${companyId}-orders`)
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'orders',
          filter: `company_id=eq.${companyId}`,
        },
        async (payload) => {
          console.log('Order changed:', payload);
          
          // Refetch order details
          const { data } = await supabase
            .from('order_details')
            .select('*')
            .eq('id', payload.new?.id || payload.old?.id)
            .single();

          if (data) {
            if (payload.eventType === 'INSERT') {
              setOrders(prev => [data, ...prev]);
            } else if (payload.eventType === 'UPDATE') {
              setOrders(prev => prev.map(o => o.id === data.id ? data : o));
            } else if (payload.eventType === 'DELETE') {
              setOrders(prev => prev.filter(o => o.id !== payload.old.id));
            }
          }
        }
      )
      .subscribe();

    return () => {
      subscription.unsubscribe();
    };
  }, [companyId]);

  return orders;
}

// ===========================================
// Example Usage in Components
// ===========================================

/*
// In a React component:

function CompanyList() {
  const { data: companies, loading, error } = useCompanies('Mumbai');

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;

  return (
    <div>
      {companies?.map(company => (
        <div key={company.id}>{company.company_name}</div>
      ))}
    </div>
  );
}

function CreateOrderForm() {
  const { mutate: createOrder, loading, error } = useCreateOrder();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    try {
      const order = await createOrder({
        company_id: 'company-uuid',
        user_id: 'user-uuid',
        plan_id: 'plan-uuid',
        vehicle_id: 'vehicle-uuid',
        // ... other fields
      });
      
      console.log('Order created:', order);
    } catch (err) {
      console.error('Failed to create order:', err);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      {error && <div>Error: {error.message}</div>}
      <button type="submit" disabled={loading}>
        {loading ? 'Creating...' : 'Create Order'}
      </button>
    </form>
  );
}

function CompanyDashboard({ companyId }: { companyId: string }) {
  const orders = useRealtimeOrders(companyId);

  return (
    <div>
      <h2>Live Orders</h2>
      {orders.map(order => (
        <div key={order.id}>
          {order.contact_name} - {order.status}
        </div>
      ))}
    </div>
  );
}
*/


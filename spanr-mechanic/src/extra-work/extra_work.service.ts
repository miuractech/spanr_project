import supabase from '../supabaseconfig';
import type { ExtraWorkRequest } from './extra_work.types';

function mapRow(row: Record<string, unknown>): ExtraWorkRequest {
  return {
    id: row.id as string,
    orderId: row.order_id as string,
    mechanicId: row.mechanic_id as string | null,
    mechanicName: (row.staff as { name?: string } | null)?.name,
    description: row.description as string,
    photoUrl: row.photo_url as string | null,
    estimatedCost: Number(row.estimated_cost),
    status: row.status as ExtraWorkRequest['status'],
    rejectionReason: row.rejection_reason as string | null,
    customerResponseAt: row.customer_response_at as string | null,
    createdAt: row.created_at as string,
    updatedAt: row.updated_at as string,
  };
}

export const extraWorkService = {
  async getByOrderId(orderId: string): Promise<ExtraWorkRequest[]> {
    const { data, error } = await supabase
      .from('extra_work_requests')
      .select('*, staff(name)')
      .eq('order_id', orderId)
      .order('created_at', { ascending: false });
    if (error) throw error;
    return (data ?? []).map((r) => mapRow(r as Record<string, unknown>));
  },

  async approve(requestId: string, orderId: string): Promise<void> {
    const { error } = await supabase
      .from('extra_work_requests')
      .update({ status: 'approved', customer_response_at: new Date().toISOString() })
      .eq('id', requestId);
    if (error) throw error;
    await this.resumeIfSettled(orderId);
  },

  async reject(requestId: string, orderId: string, reason?: string): Promise<void> {
    const { error } = await supabase
      .from('extra_work_requests')
      .update({
        status: 'rejected',
        rejection_reason: reason ?? null,
        customer_response_at: new Date().toISOString(),
      })
      .eq('id', requestId);
    if (error) throw error;
    await this.resumeIfSettled(orderId);
  },

  /** Back to in_progress once every extra-work request on the order has an answer. */
  async resumeIfSettled(orderId: string): Promise<boolean> {
    const { data, error } = await supabase
      .from('extra_work_requests')
      .select('id')
      .eq('order_id', orderId)
      .eq('status', 'pending')
      .limit(1);
    if (error) throw error;
    if (data && data.length > 0) return false;
    const { data: updated, error: orderError } = await supabase
      .from('orders')
      .update({ status: 'in_progress' })
      .eq('id', orderId)
      .eq('status', 'on_hold')
      .select('id');
    if (orderError) throw orderError;
    return (updated ?? []).length > 0;
  },
};

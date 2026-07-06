import type { OrderStatus } from '../orders/orders.types';

const STATUS_LABELS: Record<OrderStatus, string> = {
  created: 'Created',
  accepted: 'Accepted',
  assigned: 'Assigned',
  in_progress: 'In Progress',
  waiting_for_parts: 'Waiting for Parts',
  on_hold: 'On Hold',
  ready_for_delivery: 'Ready for Delivery',
  completed: 'Completed',
  dispute: 'Dispute',
  cancelled: 'Cancelled',
};

export function formatOrderStatusLabel(status: string): string {
  return STATUS_LABELS[status as OrderStatus] ?? status
    .replace(/_/g, ' ')
    .replace(/\b\w/g, (c) => c.toUpperCase());
}

export function formatOrderHistoryNotes(notes?: string): string {
  if (!notes) return '';

  const match = notes.match(/^Status changed from (.+) to (.+)$/);
  if (match) {
    return `Status changed from ${formatOrderStatusLabel(match[1])} to ${formatOrderStatusLabel(match[2])}`;
  }

  return notes;
}

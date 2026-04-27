import { Select, Button, Group, Textarea, Stack } from '@mantine/core';
import { useState } from 'react';
import type { OrderStatus } from '../orders/orders.types';

interface OrderStatusUpdaterProps {
  currentStatus: OrderStatus;
  onUpdate: (status: OrderStatus, notes?: string) => Promise<void>;
}

const statusOptions = [
  { value: 'created', label: 'Created' },
  { value: 'accepted', label: 'Accepted' },
  { value: 'in_progress', label: 'In Progress' },
  { value: 'ready_for_delivery', label: 'Ready for Delivery' },
  { value: 'completed', label: 'Completed' },
  { value: 'dispute', label: 'Dispute' },
  { value: 'cancelled', label: 'Cancelled' },
];

export const OrderStatusUpdater: React.FC<OrderStatusUpdaterProps> = ({
  currentStatus,
  onUpdate,
}) => {
  const [status, setStatus] = useState<OrderStatus>(currentStatus);
  const [notes, setNotes] = useState('');
  const [loading, setLoading] = useState(false);

  const handleUpdate = async () => {
    setLoading(true);
    try {
      await onUpdate(status, notes);
      setNotes('');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Stack gap="md">
      <Group>
        <Select
          data={statusOptions}
          value={status}
          onChange={(value) => setStatus(value as OrderStatus || currentStatus)}
          style={{ flex: 1 }}
        />
        <Button
          onClick={handleUpdate}
          loading={loading}
          disabled={status === currentStatus}
        >
          Update Status
        </Button>
      </Group>
      {status !== currentStatus && (
        <Textarea
          placeholder="Add notes about this status change..."
          value={notes}
          onChange={(e) => setNotes(e.target.value)}
          minRows={2}
        />
      )}
    </Stack>
  );
};


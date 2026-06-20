import { useState, useEffect } from 'react';
import {
  Timeline,
  Text,
  Stack,
  Title,
  Badge,
  Loader,
} from '@mantine/core';
import {
  IconCheck,
  IconClock,
  IconAlertCircle,
  IconX,
} from '@tabler/icons-react';
import { ordersService } from '../orders/orders.service';
import type { OrderHistory, OrderStatus } from '../orders/orders.types';
import { formatOrderHistoryNotes, formatOrderStatusLabel } from '../core/order_status.util';

interface OrderHistoryTimelineProps {
  orderId: string;
}

const getStatusIcon = (status: OrderStatus) => {
  switch (status) {
    case 'completed':
      return <IconCheck size={16} />;
    case 'cancelled':
      return <IconX size={16} />;
    case 'dispute':
      return <IconAlertCircle size={16} />;
    default:
      return <IconClock size={16} />;
  }
};

const getStatusColor = (status: OrderStatus) => {
  switch (status) {
    case 'completed':
      return 'green';
    case 'cancelled':
      return 'red';
    case 'dispute':
      return 'orange';
    case 'accepted':
      return 'blue';
    case 'in_progress':
      return 'cyan';
    case 'ready_for_delivery':
      return 'grape';
    default:
      return 'gray';
  }
};

export const OrderHistoryTimeline: React.FC<OrderHistoryTimelineProps> = ({ orderId }) => {
  const [history, setHistory] = useState<OrderHistory[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadHistory();
  }, [orderId]);

  const loadHistory = async () => {
    try {
      setLoading(true);
      const data = await ordersService.getOrderHistory(orderId);
      setHistory(data);
    } catch (err) {
      console.error('Failed to load order history:', err);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <Loader />;
  }

  if (history.length === 0) {
    return <Text c="dimmed">No history available.</Text>;
  }

  return (
    <Stack gap="md">
      <Title order={4}>Order History</Title>
      <Timeline active={history.length - 1}>
        {history.map((item) => (
          <Timeline.Item
            key={item.id}
            bullet={getStatusIcon(item.status)}
            title={
              <Badge color={getStatusColor(item.status)}>
                {formatOrderStatusLabel(item.status)}
              </Badge>
            }
          >
            <Text size="sm" mt={4}>
              {formatOrderHistoryNotes(item.notes)}
            </Text>
            <Text size="xs" c="dimmed" mt="xs">
              {new Date(item.created_at).toLocaleString()}
            </Text>
          </Timeline.Item>
        ))}
      </Timeline>
    </Stack>
  );
};


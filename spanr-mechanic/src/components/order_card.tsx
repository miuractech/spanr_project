import { Card, Group, Text, Badge, Stack } from '@mantine/core';
import { IconCalendar, IconCar, IconUser, IconPhone } from '@tabler/icons-react';
import type { OrderDetails } from '../orders/orders.types';

interface OrderCardProps {
  order: OrderDetails;
  onClick: (orderId: string) => void;
}

const statusColors: Record<string, string> = {
  created: 'gray',
  accepted: 'blue',
  in_progress: 'orange',
  ready_for_delivery: 'grape',
  completed: 'green',
  dispute: 'red',
  cancelled: 'red',
};

export const OrderCard: React.FC<OrderCardProps> = ({ order, onClick }) => {
  const scheduledDate = new Date(order.scheduled_service_date);

  return (
    <Card
      shadow="xs"
      padding="lg"
      radius="lg"
      style={{ 
        cursor: 'pointer',
        border: '1px solid #E0E0E0',
        transition: 'box-shadow 0.15s ease',
      }}
      onClick={() => onClick(order.id)}
    >
      <Stack gap="xs">
        <Group justify="space-between" align="flex-start">
          <div>
            <Text fw={600} c="#1C1C1C" lineClamp={1}>{order.service.name}</Text>
            <Text size="xs" c="#696969">{order.plan.name}</Text>
          </div>
          <Badge color={statusColors[order.status]} radius="sm">
            {order.status.replace('_', ' ')}
          </Badge>
        </Group>

        <Group gap="xs">
          <IconUser size={16} color="#696969" />
          <Text size="sm" c="#1C1C1C" lineClamp={1}>{order.user.name}</Text>
        </Group>

        <Group gap="xs">
          <IconPhone size={16} color="#696969" />
          <Text size="sm" c="#1C1C1C">{order.user.phone || order.contact_phone}</Text>
        </Group>
        
        {order.user.email && (
          <Text size="xs" c="#696969" lineClamp={1}>{order.user.email}</Text>
        )}

        <Group gap="xs">
          <IconCar size={16} color="#696969" />
          <Text size="sm" c="#1C1C1C" lineClamp={1}>
            {order.vehicle.make} {order.vehicle.model} ({order.vehicle.license_plate})
          </Text>
        </Group>

        <Group gap="xs">
          <IconCalendar size={16} color="#696969" />
          <Text size="sm" c="#696969">
            {scheduledDate.toLocaleDateString()} {scheduledDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
          </Text>
        </Group>

        <Group justify="space-between" mt="xs" pt="xs" style={{ borderTop: '1px solid #F2F2F2' }}>
          <Text size="sm" fw={600} c="#FC8019">
            ₹{order.payment?.amount || (Number(order.plan.base_price) * (1 + Number(order.plan.tax) / 100)).toFixed(2)}
          </Text>
          {order.payment && (
            <Badge size="sm" color={order.payment.status === 'paid' ? 'green' : 'orange'}>
              {order.payment.status}
            </Badge>
          )}
        </Group>
      </Stack>
    </Card>
  );
};

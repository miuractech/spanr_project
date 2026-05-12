import { useState, useEffect, useCallback } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
  Container,
  Title,
  Paper,
  Stack,
  Group,
  Text,
  Badge,
  Button,
  SimpleGrid,
  Alert,
  Divider,
  Tabs,
} from '@mantine/core';
import {
  IconArrowLeft,
  IconPhone,
  IconMail,
  IconMapPin,
  IconPhoto,
  IconTool,
  IconHistory,
  IconFileText,
  IconInfoCircle,
} from '@tabler/icons-react';
import { ordersService } from '../orders/orders.service';
import type { OrderDetails, OrderStatus } from '../orders/orders.types';
import { OrderActionButtons } from '../components/order_action_buttons';
import { OrderImagesManager } from '../components/order_images_manager';
import { OrderServiceDetailsForm } from '../components/order_service_details_form';
import { OrderHistoryTimeline } from '../components/order_history_timeline';
import { OrderJobCard } from '../components/order_job_card';
import { OrderDetailSkeleton } from '../components/dashboard_page_loading';

const getStatusColor = (status: OrderStatus) => {
  switch (status) {
    case 'completed': return 'green';
    case 'in_progress': return 'cyan';
    case 'accepted': return 'blue';
    case 'ready_for_delivery': return 'grape';
    case 'cancelled': return 'red';
    case 'dispute': return 'orange';
    default: return 'gray';
  }
};

export default function OrderDetailPage() {
  const { orderId } = useParams<{ orderId: string }>();
  const navigate = useNavigate();
  const [order, setOrder] = useState<OrderDetails | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const loadOrder = useCallback(async () => {
    if (!orderId) return;
    try {
      setLoading(true);
      const data = await ordersService.getOrderById(orderId);
      setOrder(data);
      setError('');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load order');
    } finally {
      setLoading(false);
    }
  }, [orderId]);

  useEffect(() => { loadOrder(); }, [loadOrder]);

  const handleStatusUpdate = async (status: OrderStatus, notes?: string) => {
    if (!orderId) return;
    try {
      await ordersService.updateOrderStatus(orderId, status, notes);
      await loadOrder();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to update status');
    }
  };

  if (loading) return <OrderDetailSkeleton />;
  if (error) return <Alert color="red">{error}</Alert>;
  if (!order) return <Alert color="yellow">Order not found</Alert>;

  const scheduledDate = new Date(order.scheduled_service_date);
  const totalAmount = Number(order.plan.base_price) * (1 + Number(order.plan.tax) / 100);

  return (
    <Container size="xl" my={24}>
      {/* Header bar */}
      <Group justify="space-between" mb="md">
        <Button
          leftSection={<IconArrowLeft size={16} />}
          variant="subtle"
          onClick={() => navigate('/orders')}
        >
          Back to Orders
        </Button>
        <Group gap="sm">
          <Title order={3}>Order #{order.id.slice(0, 8).toUpperCase()}</Title>
          <Badge size="lg" color={getStatusColor(order.status)}>
            {order.status.replace(/_/g, ' ').toUpperCase()}
          </Badge>
        </Group>
        <Text size="sm" c="dimmed">Created: {new Date(order.created_at).toLocaleString()}</Text>
      </Group>

      {/* Status actions always visible */}
      <Paper withBorder p="sm" mb="md">
        <OrderActionButtons currentStatus={order.status} onUpdate={handleStatusUpdate} />
      </Paper>

      {/* Main tab view */}
      <Tabs defaultValue="details">
        <Tabs.List>
          <Tabs.Tab value="details" leftSection={<IconInfoCircle size={16} />}>
            Order Details
          </Tabs.Tab>
          <Tabs.Tab value="jobcard" leftSection={<IconFileText size={16} />}>
            Job Card
          </Tabs.Tab>
          <Tabs.Tab value="images" leftSection={<IconPhoto size={16} />}>
            Images
          </Tabs.Tab>
          <Tabs.Tab value="service" leftSection={<IconTool size={16} />}>
            Service Details
          </Tabs.Tab>
          <Tabs.Tab value="history" leftSection={<IconHistory size={16} />}>
            History
          </Tabs.Tab>
        </Tabs.List>

        {/* ── Order Details ── */}
        <Tabs.Panel value="details" pt="md">
          <Stack gap="md">
            <SimpleGrid cols={{ base: 1, sm: 2 }}>
              <Paper withBorder p="md">
                <Text fw={600} mb="xs">Customer</Text>
                <Stack gap={4}>
                  <Text size="sm"><strong>Name:</strong> {order.user.name}</Text>
                  <Group gap="xs">
                    <IconPhone size={14} />
                    <Text size="sm">{order.user.phone}</Text>
                  </Group>
                  <Group gap="xs">
                    <IconMail size={14} />
                    <Text size="sm">{order.user.email}</Text>
                  </Group>
                  {(order.contact_name || order.contact_phone) && (
                    <>
                      <Divider my={4} />
                      <Text size="xs" c="dimmed" fw={500}>Contact on Order</Text>
                      {order.contact_name && <Text size="sm">{order.contact_name}</Text>}
                      {order.contact_phone && <Text size="sm">{order.contact_phone}</Text>}
                      {order.contact_email && <Text size="sm">{order.contact_email}</Text>}
                    </>
                  )}
                </Stack>
              </Paper>

              <Paper withBorder p="md">
                <Text fw={600} mb="xs">Vehicle</Text>
                <Stack gap={4}>
                  <Text size="sm"><strong>Make:</strong> {order.vehicle.make}</Text>
                  <Text size="sm"><strong>Model:</strong> {order.vehicle.model}</Text>
                  <Text size="sm"><strong>Year:</strong> {order.vehicle.year}</Text>
                  <Text size="sm"><strong>License Plate:</strong> {order.vehicle.license_plate}</Text>
                </Stack>
              </Paper>
            </SimpleGrid>

            <SimpleGrid cols={{ base: 1, sm: 2 }}>
              <Paper withBorder p="md">
                <Text fw={600} mb="xs">Service</Text>
                <Stack gap={4}>
                  <Text size="sm"><strong>Service:</strong> {order.service.name}</Text>
                  <Text size="sm"><strong>Plan:</strong> {order.plan.name}</Text>
                  <Text size="sm"><strong>Scheduled:</strong> {scheduledDate.toLocaleString()}</Text>
                  {order.special_instructions && (
                    <>
                      <Divider my={4} />
                      <Text size="xs" c="dimmed" fw={500}>Special Instructions</Text>
                      <Text size="sm">{order.special_instructions}</Text>
                    </>
                  )}
                </Stack>
              </Paper>

              <Paper withBorder p="md">
                <Text fw={600} mb="xs">Payment</Text>
                <Stack gap={4}>
                  <Text size="sm">Base Price: ₹{order.plan.base_price}</Text>
                  <Text size="sm">Tax ({order.plan.tax}%): ₹{(Number(order.plan.base_price) * Number(order.plan.tax) / 100).toFixed(2)}</Text>
                  <Text size="sm" fw={700}>Total: ₹{totalAmount.toFixed(2)}</Text>
                  {order.payment && (
                    <>
                      <Divider my={4} />
                      <Badge color={order.payment.status === 'paid' ? 'green' : 'orange'} size="sm">
                        {order.payment.status.toUpperCase()}
                      </Badge>
                      <Text size="sm">Method: {order.payment.method}</Text>
                      <Text size="sm">Amount: ₹{order.payment.amount}</Text>
                    </>
                  )}
                </Stack>
              </Paper>
            </SimpleGrid>

            <Paper withBorder p="md">
              <Text fw={600} mb="xs">Service Location</Text>
              <Group gap="xs" mb={4}>
                <IconMapPin size={14} />
                <Text size="sm">{order.service_address}</Text>
              </Group>
              <Text size="xs" c="dimmed">
                {order.service_latitude}, {order.service_longitude}
              </Text>
            </Paper>
          </Stack>
        </Tabs.Panel>

        {/* ── Job Card ── */}
        <Tabs.Panel value="jobcard" pt="md">
          <OrderJobCard orderId={orderId!} order={order} />
        </Tabs.Panel>

        {/* ── Images ── */}
        <Tabs.Panel value="images" pt="md">
          <OrderImagesManager orderId={orderId!} />
        </Tabs.Panel>

        {/* ── Service Details ── */}
        <Tabs.Panel value="service" pt="md">
          <OrderServiceDetailsForm orderId={orderId!} />
        </Tabs.Panel>

        {/* ── History ── */}
        <Tabs.Panel value="history" pt="md">
          <OrderHistoryTimeline orderId={orderId!} />
        </Tabs.Panel>
      </Tabs>
    </Container>
  );
}

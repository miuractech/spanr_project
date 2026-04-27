import { useState, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Container,
  Title,
  Alert,
  SimpleGrid,
  Group,
  Select,
  Paper,
  Text,
  Stack,
  TextInput,
  Pagination,
  Loader,
  Center,
} from '@mantine/core';
import { DatePickerInput } from '@mantine/dates';
import { IconAlertCircle, IconSearch } from '@tabler/icons-react';
import { useDebouncedValue } from '@mantine/hooks';
import { useCompany } from '../company/company.hook';
import { useOrders, useOrderStats } from '../orders/orders.hook';
import { OrderCard } from '../components/order_card';
import type { OrderStatus, OrderFilters } from '../orders/orders.types';

export default function OrdersPage() {
  const navigate = useNavigate();
  const { company } = useCompany();
  const [statusFilter, setStatusFilter] = useState<string>('all');
  const [dateRange, setDateRange] = useState<[Date | null, Date | null]>([null, null]);
  const [searchQuery, setSearchQuery] = useState('');
  const [page, setPage] = useState(1);
  const [debouncedSearch] = useDebouncedValue(searchQuery, 500);

  const filters = useMemo<OrderFilters>(() => ({
    status: statusFilter !== 'all' ? statusFilter as OrderStatus : undefined,
    startDate: dateRange[0] || undefined,
    endDate: dateRange[1] || undefined,
    search: debouncedSearch || undefined,
  }), [statusFilter, dateRange, debouncedSearch]);

  const { 
    orders, 
    total, 
    totalPages, 
    loading, 
    error 
  } = useOrders(company?.id, page, 10, filters);

  const { stats } = useOrderStats(company?.id);

  const handleViewOrder = (orderId: string) => {
    navigate(`/orders/${orderId}`);
  };

  const handleFilterChange = () => {
    setPage(1); // Reset to first page when filters change
  };

  if (error) return <Alert color="red">{error}</Alert>;
  if (!company) return <Alert color="yellow">No company profile found</Alert>;

  return (
    <Container size="xl" my={40}>
      <Title mb="xl">Orders Management</Title>

      <SimpleGrid cols={{ base: 2, sm: 4, md: 7 }} mb="xl">
        <Paper withBorder p="md" radius="md" style={{ backgroundColor: '#FFFFFF' }}>
          <Text size="sm" c="dimmed" tt="uppercase" fw={600}>Total</Text>
          <Text size="xl" fw={700} c="orange">{stats.total}</Text>
        </Paper>
        <Paper withBorder p="md" radius="md" style={{ backgroundColor: '#FFFFFF' }}>
          <Text size="sm" c="dimmed" tt="uppercase" fw={600}>Created</Text>
          <Text size="xl" fw={700} c="gray">{stats.created}</Text>
        </Paper>
        <Paper withBorder p="md" radius="md" style={{ backgroundColor: '#FFFFFF' }}>
          <Text size="sm" c="dimmed" tt="uppercase" fw={600}>Accepted</Text>
          <Text size="xl" fw={700} c="orange">{stats.accepted}</Text>
        </Paper>
        <Paper withBorder p="md" radius="md" style={{ backgroundColor: '#FFFFFF' }}>
          <Text size="sm" c="dimmed" tt="uppercase" fw={600}>In Progress</Text>
          <Text size="xl" fw={700} c="orange">{stats.inProgress}</Text>
        </Paper>
        <Paper withBorder p="md" radius="md" style={{ backgroundColor: '#FFFFFF' }}>
          <Text size="sm" c="dimmed" tt="uppercase" fw={600}>Ready</Text>
          <Text size="xl" fw={700} c="orange">{stats.readyForDelivery}</Text>
        </Paper>
        <Paper withBorder p="md" radius="md" style={{ backgroundColor: '#FFFFFF' }}>
          <Text size="sm" c="dimmed" tt="uppercase" fw={600}>Completed</Text>
          <Text size="xl" fw={700} c="green">{stats.completed}</Text>
        </Paper>
        <Paper withBorder p="md" radius="md" style={{ backgroundColor: '#FFFFFF' }}>
          <Text size="sm" c="dimmed" tt="uppercase" fw={600}>Dispute</Text>
          <Text size="xl" fw={700} c="orange">{stats.dispute}</Text>
        </Paper>
      </SimpleGrid>

      <Stack gap="md" mb="xl">
        <TextInput
          placeholder="Search by customer name, email, or phone..."
          leftSection={<IconSearch size={16} />}
          value={searchQuery}
          onChange={(e) => {
            setSearchQuery(e.target.value);
            handleFilterChange();
          }}
        />

        <Group>
          <Select
            placeholder="Filter by status"
            data={[
              { value: 'all', label: 'All Statuses' },
              { value: 'created', label: 'Created' },
              { value: 'accepted', label: 'Accepted' },
              { value: 'in_progress', label: 'In Progress' },
              { value: 'ready_for_delivery', label: 'Ready for Delivery' },
              { value: 'completed', label: 'Completed' },
              { value: 'dispute', label: 'Dispute' },
              { value: 'cancelled', label: 'Cancelled' },
            ]}
            value={statusFilter}
            onChange={(value) => {
              setStatusFilter(value || 'all');
              handleFilterChange();
            }}
            style={{ width: 200 }}
            clearable
          />

          <DatePickerInput
            type="range"
            placeholder="Filter by date range"
            value={dateRange}
            onChange={(value) => {
              setDateRange(value);
              handleFilterChange();
            }}
            style={{ width: 300 }}
            clearable
          />
        </Group>
      </Stack>

      {loading ? (
        <Center h={200}>
          <Loader />
        </Center>
      ) : orders.length === 0 ? (
        <Alert icon={<IconAlertCircle size={16} />} color="blue">
          <Text>No orders found.</Text>
        </Alert>
      ) : (
        <Stack gap="xl">
          <SimpleGrid cols={{ base: 1, sm: 2, md: 3 }}>
            {orders.map((order) => (
              <OrderCard key={order.id} order={order} onClick={handleViewOrder} />
            ))}
          </SimpleGrid>

          {totalPages > 1 && (
            <Center>
              <Pagination
                total={totalPages}
                value={page}
                onChange={setPage}
              />
            </Center>
          )}

          <Text size="sm" c="dimmed" ta="center">
            Showing {orders.length} of {total} orders
          </Text>
        </Stack>
      )}
    </Container>
  );
}


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
  Center,
} from '@mantine/core';
import { DatePickerInput } from '@mantine/dates';
import type { DatesRangeValue } from '@mantine/dates';
import { IconAlertCircle, IconSearch } from '@tabler/icons-react';
import { useDebouncedValue } from '@mantine/hooks';
import { useCompany } from '../company/company.hook';
import { useOrders, useOrderStats } from '../orders/orders.hook';
import { OrderCard } from '../components/order_card';
import { OrdersListSkeleton } from '../components/dashboard_page_loading';
import type { OrderStatus, OrderFilters } from '../orders/orders.types';

const statConfig = [
  { key: 'total', label: 'Total', color: '#FC8019' },
  { key: 'created', label: 'Created', color: '#696969' },
  { key: 'accepted', label: 'Accepted', color: '#1976D2' },
  { key: 'inProgress', label: 'In Progress', color: '#FC8019' },
  { key: 'readyForDelivery', label: 'Ready', color: '#7B1FA2' },
  { key: 'completed', label: 'Completed', color: '#267E3E' },
  { key: 'dispute', label: 'Dispute', color: '#D32F2F' },
] as const;

export default function OrdersPage() {
  const navigate = useNavigate();
  const { company } = useCompany();
  const [statusFilter, setStatusFilter] = useState<string>('all');
  const [dateRange, setDateRange] = useState<DatesRangeValue<string>>([null, null]);
  const [searchQuery, setSearchQuery] = useState('');
  const [page, setPage] = useState(1);
  const [debouncedSearch] = useDebouncedValue(searchQuery, 500);

  const filters = useMemo<OrderFilters>(() => ({
    status: statusFilter !== 'all' ? statusFilter as OrderStatus : undefined,
    startDate: dateRange[0] ? new Date(dateRange[0]) : undefined,
    endDate: dateRange[1] ? new Date(dateRange[1]) : undefined,
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
    setPage(1);
  };

  if (error) return <Alert color="red">{error}</Alert>;
  if (!company) return <Alert color="yellow">No company profile found</Alert>;

  return (
    <Container size="xl" my={40}>
      <Title mb="xl" c="#1C1C1C">Orders Management</Title>

      <SimpleGrid cols={{ base: 2, sm: 4, md: 7 }} mb="xl">
        {statConfig.map((s) => (
          <Paper
            key={s.key}
            p="md"
            radius="lg"
            style={{ border: '1px solid #E0E0E0' }}
          >
            <Text size="xs" c="#696969" tt="uppercase" fw={600}>{s.label}</Text>
            <Text size="xl" fw={700} style={{ color: s.color }}>
              {stats[s.key as keyof typeof stats]}
            </Text>
          </Paper>
        ))}
      </SimpleGrid>

      <Paper p="lg" radius="lg" mb="xl" style={{ border: '1px solid #E0E0E0' }}>
        <Stack gap="md">
          <TextInput
            label="Search orders"
            placeholder="Customer name, email, or phone"
            leftSection={<IconSearch size={18} stroke={1.5} />}
            leftSectionWidth={40}
            value={searchQuery}
            onChange={(e) => {
              setSearchQuery(e.target.value);
              handleFilterChange();
            }}
          />

          <Group align="flex-end" grow preventGrowOverflow={false} wrap="wrap">
            <Select
              label="Status"
              placeholder="All statuses"
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
              style={{ flex: '1 1 200px', minWidth: 200 }}
              clearable
            />

            <DatePickerInput
              type="range"
              label="Date range"
              placeholder="Select dates"
              value={dateRange}
              onChange={(value) => {
                setDateRange(value);
                handleFilterChange();
              }}
              style={{ flex: '1 1 280px', minWidth: 280 }}
              clearable
            />
          </Group>
        </Stack>
      </Paper>

      {loading ? (
        <OrdersListSkeleton />
      ) : orders.length === 0 ? (
        <Alert icon={<IconAlertCircle size={16} />} color="blue" radius="md">
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
                color="orange"
              />
            </Center>
          )}

          <Text size="sm" c="#696969" ta="center">
            Showing {orders.length} of {total} orders
          </Text>
        </Stack>
      )}
    </Container>
  );
}

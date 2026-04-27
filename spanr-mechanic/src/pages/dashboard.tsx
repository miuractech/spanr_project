import {
  Container,
  Title,
  SimpleGrid,
  Paper,
  Text,
  Stack,
  Group,
} from '@mantine/core';
import { IconShoppingCart, IconUsers, IconTools, IconClipboardList } from '@tabler/icons-react';
import { useCompany } from '../company/company.hook';
import { useOrderStats } from '../orders/orders.hook';
import { useServices } from '../services/services.hook';
import { usePlans } from '../plans/plans.hook';
import { useStaff } from '../staff/staff.hook';

export default function DashboardPage() {
  const { company } = useCompany();
  const { stats: orderStats } = useOrderStats(company?.id);
  const { services } = useServices(company?.id);
  const { plans } = usePlans(company?.id);
  const { staff } = useStaff(company?.id);

  const statCards = [
    {
      title: 'Total Orders',
      value: orderStats.total,
      icon: IconShoppingCart,
      color: 'orange',
    },
    {
      title: 'Active Services',
      value: services.length,
      icon: IconTools,
      color: 'orange',
    },
    {
      title: 'Service Plans',
      value: plans.length,
      icon: IconClipboardList,
      color: 'orange',
    },
    {
      title: 'Staff Members',
      value: staff.filter(s => s.enabled).length,
      icon: IconUsers,
      color: 'orange',
    },
  ];

  return (
    <Container size="xl" my={40}>
      <Title mb="xl">Dashboard</Title>

      <SimpleGrid cols={{ base: 1, sm: 2, md: 4 }} mb="xl">
        {statCards.map((stat) => {
          const Icon = stat.icon;
          return (
            <Paper key={stat.title} withBorder p="md" radius="md">
              <Group justify="space-between">
                <Stack gap={0}>
                  <Text size="xs" c="dimmed" tt="uppercase" fw={700}>
                    {stat.title}
                  </Text>
                  <Text size="xl" fw={700}>
                    {stat.value}
                  </Text>
                </Stack>
                <Icon size={32} color={`var(--mantine-color-${stat.color}-6)`} />
              </Group>
            </Paper>
          );
        })}
      </SimpleGrid>

      <SimpleGrid cols={{ base: 1, md: 2 }}>
        <Paper withBorder p="md">
          <Title order={3} mb="md">Order Status</Title>
          <Stack gap="xs">
            <Group justify="space-between">
              <Text>Pending</Text>
              <Text fw={500}>{orderStats.pending}</Text>
            </Group>
            <Group justify="space-between">
              <Text>Confirmed</Text>
              <Text fw={500}>{orderStats.confirmed}</Text>
            </Group>
            <Group justify="space-between">
              <Text>In Progress</Text>
              <Text fw={500}>{orderStats.inProgress}</Text>
            </Group>
            <Group justify="space-between">
              <Text>Completed</Text>
              <Text fw={500}>{orderStats.completed}</Text>
            </Group>
          </Stack>
        </Paper>

        <Paper withBorder p="md">
          <Title order={3} mb="md">Quick Stats</Title>
          <Stack gap="xs">
            <Text>Welcome to your SPANR dashboard!</Text>
            <Text size="sm" c="dimmed">
              Manage your mechanic business from here.
            </Text>
          </Stack>
        </Paper>
      </SimpleGrid>
    </Container>
  );
}


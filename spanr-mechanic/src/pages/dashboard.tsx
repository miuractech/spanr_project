import {
  Container,
  Title,
  SimpleGrid,
  Paper,
  Text,
  Stack,
  Group,
  ThemeIcon,
} from '@mantine/core';
import { IconShoppingCart, IconUsers, IconTools, IconClipboardList } from '@tabler/icons-react';
import { useCompany } from '../company/company.hook';
import { useOrderStats } from '../orders/orders.hook';
import { useServices } from '../services/services.hook';
import { usePlans } from '../plans/plans.hook';
import { useStaff } from '../staff/staff.hook';
import { isStaffAuthEmail } from '../core/phone.util';

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
      bg: '#FFF3E0',
      iconColor: '#FC8019',
    },
    {
      title: 'Active Services',
      value: services.length,
      icon: IconTools,
      bg: '#E8F5E9',
      iconColor: '#267E3E',
    },
    {
      title: 'Service Plans',
      value: plans.length,
      icon: IconClipboardList,
      bg: '#E3F2FD',
      iconColor: '#1976D2',
    },
    {
      title: 'Mechanics',
      value: staff.filter((s) => s.enabled && isStaffAuthEmail(s.email)).length,
      icon: IconUsers,
      bg: '#F3E5F5',
      iconColor: '#7B1FA2',
    },
  ];

  return (
    <Container size="xl" my={40}>
      <Title mb="xl" c="#1C1C1C">Dashboard</Title>

      <SimpleGrid cols={{ base: 1, sm: 2, md: 4 }} mb="xl">
        {statCards.map((stat) => {
          const Icon = stat.icon;
          return (
            <Paper
              key={stat.title}
              p="lg"
              radius="lg"
              style={{ border: '1px solid #E0E0E0' }}
            >
              <Group justify="space-between" align="flex-start">
                <Stack gap={4}>
                  <Text size="xs" c="#696969" tt="uppercase" fw={600}>
                    {stat.title}
                  </Text>
                  <Text size="xl" fw={700} c="#1C1C1C">
                    {stat.value}
                  </Text>
                </Stack>
                <ThemeIcon
                  size={44}
                  radius="lg"
                  variant="light"
                  style={{ backgroundColor: stat.bg, color: stat.iconColor }}
                >
                  <Icon size={22} />
                </ThemeIcon>
              </Group>
            </Paper>
          );
        })}
      </SimpleGrid>

      <SimpleGrid cols={{ base: 1, md: 2 }}>
        <Paper p="lg" radius="lg" style={{ border: '1px solid #E0E0E0' }}>
          <Title order={3} mb="md" c="#1C1C1C">Order Status</Title>
          <Stack gap="sm">
            {[
              { label: 'Created', value: orderStats.created, color: '#696969' },
              { label: 'Accepted', value: orderStats.accepted, color: '#FC8019' },
              { label: 'In Progress', value: orderStats.inProgress, color: '#1976D2' },
              { label: 'Completed', value: orderStats.completed, color: '#267E3E' },
            ].map((item) => (
              <Group key={item.label} justify="space-between">
                <Text size="sm" c="#696969">{item.label}</Text>
                <Text fw={600} c={item.color}>{item.value}</Text>
              </Group>
            ))}
          </Stack>
        </Paper>

        <Paper p="lg" radius="lg" style={{ border: '1px solid #E0E0E0' }}>
          <Title order={3} mb="md" c="#1C1C1C">Quick Stats</Title>
          <Stack gap="xs">
            <Text c="#1C1C1C">Welcome to your SPANR dashboard!</Text>
            <Text size="sm" c="#696969">
              Manage your mechanic business from here.
            </Text>
          </Stack>
        </Paper>
      </SimpleGrid>
    </Container>
  );
}

import { useCallback, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Container,
  Title,
  Tabs,
  Badge,
  Button,
  Group,
  Text,
  Loader,
  Center,
  Paper,
  Stack,
  ThemeIcon,
} from '@mantine/core';
import { IconBuildingStore, IconMapPin, IconPhone } from '@tabler/icons-react';
import { adminService, type AdminCompanyRow } from './admin.service';
import { useNotification } from '../core/notification.hook';

type StatusFilter = 'pending' | 'verified' | 'rejected';

const STATUS_COLOR: Record<StatusFilter, string> = {
  pending: 'orange',
  verified: 'green',
  rejected: 'red',
};

export default function AdminDashboardPage() {
  const navigate = useNavigate();
  const { showError } = useNotification();
  const [tab, setTab] = useState<StatusFilter>('pending');
  const [companies, setCompanies] = useState<AdminCompanyRow[]>([]);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      setCompanies(await adminService.listCompanies(tab));
    } catch (err) {
      showError(err instanceof Error ? err.message : 'Failed to load shops');
    } finally {
      setLoading(false);
    }
  }, [tab, showError]);

  useEffect(() => {
    void load();
  }, [load]);

  return (
    <Container size="xl" my={40}>
      <Title mb="xs" c="#1C1C1C">
        Shop approval
      </Title>
      <Text size="sm" c="#696969" mb="xl">
        Review KYC documents. A shop appears in the customer app only after you verify it.
      </Text>

      <Tabs value={tab} onChange={(v) => setTab((v as StatusFilter) ?? 'pending')} mb="xl">
        <Tabs.List>
          <Tabs.Tab value="pending">Pending</Tabs.Tab>
          <Tabs.Tab value="verified">Verified</Tabs.Tab>
          <Tabs.Tab value="rejected">Rejected</Tabs.Tab>
        </Tabs.List>
      </Tabs>

      {loading ? (
        <Center py="xl">
          <Loader color="orange" />
        </Center>
      ) : companies.length === 0 ? (
        <Paper p="xl" radius="lg" style={{ border: '1px solid #E0E0E0' }}>
          <Text c="#696969" ta="center">
            No shops in this state.
          </Text>
        </Paper>
      ) : (
        <Stack gap="md">
          {companies.map((c) => (
            <Paper
              key={c.id}
              p="lg"
              radius="lg"
              style={{ border: '1px solid #E0E0E0' }}
            >
              <Group justify="space-between" align="flex-start" wrap="wrap">
                <Group align="flex-start" gap="md" wrap="nowrap" style={{ flex: 1, minWidth: 0 }}>
                  <ThemeIcon size={48} radius="md" color="orange" variant="light">
                    <IconBuildingStore size={24} />
                  </ThemeIcon>
                  <Stack gap={4} style={{ minWidth: 0 }}>
                    <Group gap="xs">
                      <Text fw={700} c="#1C1C1C" size="md">
                        {c.company_name}
                      </Text>
                      <Badge color={STATUS_COLOR[c.verification_status]}>
                        {c.verification_status}
                      </Badge>
                    </Group>
                    <Group gap={16}>
                      <Group gap={6}>
                        <IconMapPin size={14} color="#696969" />
                        <Text size="sm" c="#696969">
                          {c.city}
                          {c.state ? `, ${c.state}` : ''}
                        </Text>
                      </Group>
                      {c.phone && (
                        <Group gap={6}>
                          <IconPhone size={14} color="#696969" />
                          <Text size="sm" c="#696969">
                            {c.phone}
                          </Text>
                        </Group>
                      )}
                    </Group>
                  </Stack>
                </Group>
                <Button
                  color="orange"
                  variant="light"
                  onClick={() => navigate(`/admin/shops/${c.id}`)}
                >
                  Review
                </Button>
              </Group>
            </Paper>
          ))}
        </Stack>
      )}
    </Container>
  );
}

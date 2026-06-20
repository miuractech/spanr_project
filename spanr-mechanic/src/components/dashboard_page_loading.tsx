import {
  Container,
  Skeleton,
  Stack,
  SimpleGrid,
  Paper,
  Group,
  Table,
  Box,
} from '@mantine/core';

/** First paint while company profile is loading (layout-level). */
export function DashboardRouteSkeleton() {
  return (
    <Container size="xl" my={40}>
      <Skeleton height={40} width={280} mb="xl" radius="sm" />
      <SimpleGrid cols={{ base: 1, sm: 2, md: 4 }} mb="xl">
        {[0, 1, 2, 3].map((i) => (
          <Paper key={i} p="lg" radius="lg" style={{ border: '1px solid #E0E0E0' }}>
            <Group justify="space-between" align="flex-start" wrap="nowrap">
              <Stack gap={8} style={{ flex: 1 }}>
                <Skeleton height={12} width="65%" />
                <Skeleton height={32} width={36} />
              </Stack>
              <Skeleton height={44} width={44} radius="lg" />
            </Group>
          </Paper>
        ))}
      </SimpleGrid>
      <SimpleGrid cols={{ base: 1, md: 2 }}>
        <Paper p="lg" radius="lg" style={{ border: '1px solid #E0E0E0' }}>
          <Skeleton height={26} width="45%" mb="md" />
          <Stack gap="sm">
            {[1, 2, 3, 4].map((i) => (
              <Group key={i} justify="space-between">
                <Skeleton height={16} width="35%" />
                <Skeleton height={16} width={24} />
              </Group>
            ))}
          </Stack>
        </Paper>
        <Paper p="lg" radius="lg" style={{ border: '1px solid #E0E0E0' }}>
          <Skeleton height={26} width="40%" mb="md" />
          <Skeleton height={48} mb="sm" />
          <Skeleton height={14} width="90%" />
        </Paper>
      </SimpleGrid>
    </Container>
  );
}

export function OrdersListSkeleton() {
  return (
    <SimpleGrid cols={{ base: 1, sm: 2, md: 3 }}>
      {[1, 2, 3, 4, 5, 6].map((i) => (
        <Paper key={i} p="md" radius="lg" style={{ border: '1px solid #E0E0E0' }}>
          <Skeleton height={14} width="72%" mb="sm" />
          <Skeleton height={12} width="88%" mb={6} />
          <Skeleton height={12} width="55%" mb="md" />
          <Group justify="space-between" mt="md">
            <Skeleton height={12} width={64} />
            <Skeleton height={24} width={80} radius="xl" />
          </Group>
        </Paper>
      ))}
    </SimpleGrid>
  );
}

export function StaffTableSkeleton() {
  return (
    <Paper radius="lg" style={{ border: '1px solid #E0E0E0', overflow: 'hidden' }}>
      <Table verticalSpacing="md" horizontalSpacing="lg">
        <Table.Thead>
          <Table.Tr>
            {['Name', 'Email', 'Status', 'Permissions', 'Actions'].map((h) => (
              <Table.Th key={h}>
                <Skeleton height={14} width={h.length * 8} />
              </Table.Th>
            ))}
          </Table.Tr>
        </Table.Thead>
        <Table.Tbody>
          {[1, 2, 3, 4, 5].map((row) => (
            <Table.Tr key={row}>
              {[40, 180, 70, 120, 72].map((w, j) => (
                <Table.Td key={j}>
                  <Skeleton height={16} width={w} />
                </Table.Td>
              ))}
            </Table.Tr>
          ))}
        </Table.Tbody>
      </Table>
    </Paper>
  );
}

export function CompanyProfileFormSkeleton() {
  return (
    <Stack gap="xl">
      <Group gap="md" wrap="nowrap">
        {[1, 2, 3, 4].map((i) => (
          <Box key={i} style={{ flex: 1 }}>
            <Skeleton height={36} circle mb="xs" mx="auto" />
            <Skeleton height={10} width="60%" mx="auto" />
          </Box>
        ))}
      </Group>
      <Paper p="xl" radius="lg" style={{ border: '1px solid #E0E0E0' }}>
        <Stack gap="lg">
          <Skeleton height={28} width="50%" />
          {[1, 2, 3, 4].map((i) => (
            <Stack key={i} gap="xs">
              <Skeleton height={12} width={100} />
              <Skeleton height={44} radius="md" />
            </Stack>
          ))}
        </Stack>
      </Paper>
    </Stack>
  );
}

export function ServicesPlansSkeleton() {
  return (
    <Stack gap="lg">
      <Box>
        <Group justify="space-between" mb="md">
          <Skeleton height={32} width={180} radius="sm" />
          <Skeleton height={36} width={130} radius="md" />
        </Group>
        <SimpleGrid cols={{ base: 1, sm: 2, md: 3, lg: 4 }}>
          {[1, 2, 3, 4].map((i) => (
            <Paper key={i} p="lg" radius="lg" style={{ border: '1px solid #E8E8E8' }}>
              <Group gap="sm" mb="sm">
                <Skeleton height={40} width={40} radius="md" />
                <Stack gap={6} style={{ flex: 1 }}>
                  <Skeleton height={16} width="70%" />
                  <Skeleton height={12} width="40%" />
                </Stack>
              </Group>
              <Skeleton height={22} width={56} radius="xl" />
            </Paper>
          ))}
        </SimpleGrid>
      </Box>
      <Skeleton height={1} width="100%" />
      <Box>
        <Group justify="space-between" mb="md">
          <Skeleton height={32} width={140} radius="sm" />
          <Skeleton height={36} width={120} radius="md" />
        </Group>
        <SimpleGrid cols={{ base: 1, sm: 2, md: 3, lg: 4 }}>
          {[1, 2, 3].map((i) => (
            <Paper key={i} p="lg" radius="lg" style={{ border: '1px solid #E8E8E8', borderTop: '3px solid #FC8019' }}>
              <Skeleton height={20} width="65%" mb="sm" />
              <Skeleton height={14} width="50%" mb="md" />
              <Group gap={6} mb="md">
                <Skeleton height={22} width={48} radius="xl" />
                <Skeleton height={22} width={72} radius="xl" />
              </Group>
              <Group justify="space-between" pt="sm" style={{ borderTop: '1px solid #F0F0F0' }}>
                <Skeleton height={16} width={64} />
                <Skeleton height={20} width={56} />
              </Group>
            </Paper>
          ))}
        </SimpleGrid>
      </Box>
    </Stack>
  );
}

export function PlanDetailSkeleton() {
  return (
    <Container size="lg" my={40}>
      <Skeleton height={36} width={160} mb="xl" radius="md" />
      <Paper p="xl" radius="lg" style={{ border: '1px solid #E0E0E0' }}>
        <Stack gap="xl">
          <Skeleton height={36} width="55%" />
          <Group gap="sm">
            <Skeleton height={24} width={72} radius="xl" />
            <Skeleton height={24} width={88} radius="xl" />
          </Group>
          <SimpleGrid cols={{ base: 1, sm: 3 }}>
            {[1, 2, 3].map((i) => (
              <Skeleton key={i} height={72} radius="md" />
            ))}
          </SimpleGrid>
          <Skeleton height={120} radius="md" />
          <Skeleton height={200} radius="md" />
        </Stack>
      </Paper>
    </Container>
  );
}

export function OrderDetailSkeleton() {
  return (
    <Container size="xl" my={24}>
      <Skeleton height={36} width={160} mb="md" />
      <Paper p="lg" radius="lg" mb="lg" style={{ border: '1px solid #E0E0E0' }}>
        <Group justify="space-between" mb="lg">
          <Stack gap={8}>
            <Skeleton height={28} width={220} />
            <Skeleton height={16} width={160} />
          </Stack>
          <Skeleton height={32} width={100} radius="md" />
        </Group>
        <SimpleGrid cols={{ base: 1, md: 2 }} mb="lg">
          {[1, 2, 3, 4].map((i) => (
            <Skeleton key={i} height={56} radius="md" />
          ))}
        </SimpleGrid>
        <Skeleton height={240} radius="md" />
      </Paper>
    </Container>
  );
}

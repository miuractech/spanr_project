import { useState } from 'react';
import { Container, Title, TextInput, Group } from '@mantine/core';
import { IconSearch } from '@tabler/icons-react';
import { useCompany } from '../company/company.hook';
import { VehicleHistoryTimeline } from '../components/vehicle_history_timeline';

export default function VehicleHistoryPage() {
  const { company } = useCompany();
  const [search, setSearch] = useState('');
  const [query, setQuery] = useState('');

  if (!company) return null;

  return (
    <Container size="xl" my={40}>
      <Title mb="md" c="#1C1C1C">Vehicle Service History</Title>
      <Group mb="xl">
        <TextInput
          placeholder="Search by license plate..."
          leftSection={<IconSearch size={16} />}
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          onKeyDown={(e) => e.key === 'Enter' && setQuery(search)}
          style={{ flex: 1 }}
        />
      </Group>
      <VehicleHistoryTimeline companyId={company.id} searchPlate={query} />
    </Container>
  );
}

import { Paper, Stack, Text, Group, Badge, SimpleGrid, Image, Divider } from '@mantine/core';
import type { ServiceRecordDetail } from '../vehicle-history/vehicle_history.types';

interface ServiceRecordCardProps {
  record: ServiceRecordDetail;
}

export const ServiceRecordCard: React.FC<ServiceRecordCardProps> = ({ record }) => {
  const beforeImages = record.inspection_images.filter((i) => i.type === 'before');
  const afterImages = record.inspection_images.filter((i) => i.type === 'after');

  return (
    <Paper withBorder p="md" radius="md">
      <Group justify="space-between" mb="sm">
        <div>
          <Text fw={600}>{record.license_plate} — {record.vehicle_make} {record.vehicle_model}</Text>
          <Text size="sm" c="dimmed">{new Date(record.service_date).toLocaleString()}</Text>
        </div>
        <Badge color="green">Completed</Badge>
      </Group>

      <SimpleGrid cols={{ base: 1, sm: 2 }} mb="sm">
        <Text size="sm"><strong>Customer:</strong> {record.customer_name}</Text>
        <Text size="sm"><strong>Mechanic:</strong> {record.mechanic_name}</Text>
        <Text size="sm"><strong>Service:</strong> {record.services_performed}</Text>
        {record.odometer_reading && (
          <Text size="sm"><strong>Odometer:</strong> {record.odometer_reading} km</Text>
        )}
      </SimpleGrid>

      {record.service_notes && (
        <Text size="sm" mb="sm"><strong>Notes:</strong> {record.service_notes}</Text>
      )}

      {record.parts.length > 0 && (
        <>
          <Divider my="sm" label="Parts Replaced" labelPosition="left" />
          <Stack gap="xs">
            {record.parts.map((part) => (
              <Group key={part.id} justify="space-between">
                <div>
                  <Text size="sm" fw={500}>{part.part_name}</Text>
                  {part.part_number && <Text size="xs" c="dimmed">#{part.part_number}</Text>}
                </div>
                <Group gap="xs">
                  <Badge size="sm" variant="light">Qty: {part.quantity}</Badge>
                  {part.cost != null && <Badge size="sm" color="orange">₹{part.cost}</Badge>}
                </Group>
              </Group>
            ))}
          </Stack>
        </>
      )}

      {(beforeImages.length > 0 || afterImages.length > 0) && (
        <>
          <Divider my="sm" label="Inspection Photos" labelPosition="left" />
          {beforeImages.length > 0 && (
            <Text size="xs" fw={500} mb={4}>Before</Text>
          )}
          <Group gap="xs" mb="sm">
            {beforeImages.map((img) => (
              <Image key={img.id} src={img.image_url} w={80} h={60} radius="sm" fit="cover" />
            ))}
          </Group>
          {afterImages.length > 0 && (
            <Text size="xs" fw={500} mb={4}>After</Text>
          )}
          <Group gap="xs">
            {afterImages.map((img) => (
              <Image key={img.id} src={img.image_url} w={80} h={60} radius="sm" fit="cover" />
            ))}
          </Group>
        </>
      )}
    </Paper>
  );
};

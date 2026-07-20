import { Card, Group, Text, Badge, ActionIcon, Stack, ThemeIcon, Box } from '@mantine/core';
import { IconEdit, IconTrash, IconTools, IconMotorbike } from '@tabler/icons-react';
import type { DbService } from '../types';

interface ServiceCardProps {
  service: DbService;
  planCount: number;
  selected?: boolean;
  onSelect: (serviceId: string) => void;
  onEdit: (service: DbService) => void;
  onDelete: (serviceId: string) => void;
}

export const ServiceCard: React.FC<ServiceCardProps> = ({
  service,
  planCount,
  selected = false,
  onSelect,
  onEdit,
  onDelete,
}) => {
  const CategoryIcon = service.category === 'bike' ? IconMotorbike : IconTools;

  return (
    <Card
      padding="lg"
      radius="lg"
      withBorder
      onClick={() => onSelect(service.id)}
      style={{
        cursor: 'pointer',
        borderColor: selected ? '#1976D2' : '#E0E0E0',
        borderWidth: selected ? 2 : 1,
        backgroundColor: selected ? '#F5F9FF' : '#FFFFFF',
        transition: 'box-shadow 0.2s ease, border-color 0.2s ease, transform 0.15s ease',
      }}
      onMouseEnter={(e) => {
        if (!selected) {
          e.currentTarget.style.boxShadow = '0 4px 16px rgba(25, 118, 210, 0.12)';
        }
      }}
      onMouseLeave={(e) => {
        e.currentTarget.style.boxShadow = 'none';
      }}
    >
      <Group justify="space-between" align="flex-start" wrap="nowrap" mb="sm">
        <Group gap="sm" wrap="nowrap" style={{ flex: 1, minWidth: 0 }}>
          <ThemeIcon size={40} radius="md" variant="light" color="blue">
            <CategoryIcon size={20} />
          </ThemeIcon>
          <Box style={{ minWidth: 0 }}>
            <Text fw={700} size="md" c="#1C1C1C" lineClamp={1}>
              {service.name}
            </Text>
            <Text size="xs" c="#696969" mt={2}>
              {planCount} plan{planCount !== 1 ? 's' : ''}
            </Text>
          </Box>
        </Group>
        <Group gap={4} onClick={(e) => e.stopPropagation()}>
          <ActionIcon variant="light" color="blue" size="sm" onClick={() => onEdit(service)}>
            <IconEdit size={15} />
          </ActionIcon>
          <ActionIcon variant="light" color="red" size="sm" onClick={() => onDelete(service.id)}>
            <IconTrash size={15} />
          </ActionIcon>
        </Group>
      </Group>

      <Stack gap="xs">
        <Badge
          size="sm"
          variant="light"
          color="teal"
          w="fit-content"
        >
          Bike
        </Badge>
        {service.description && (
          <Text size="sm" c="#696969" lineClamp={2}>
            {service.description}
          </Text>
        )}
      </Stack>
    </Card>
  );
};

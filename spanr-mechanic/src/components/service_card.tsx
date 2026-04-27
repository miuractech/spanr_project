import { Card, Group, Text, Badge, ActionIcon, Image } from '@mantine/core';
import { IconEdit, IconTrash } from '@tabler/icons-react';
import type { DbService } from '../types';

interface ServiceCardProps {
  service: DbService;
  onEdit: (service: DbService) => void;
  onDelete: (serviceId: string) => void;
}

export const ServiceCard: React.FC<ServiceCardProps> = ({ service, onEdit, onDelete }) => {
  return (
    <Card 
      withBorder 
      shadow="sm" 
      padding="lg"
      radius="md"
      style={{ 
        backgroundColor: '#FFFFFF',
        border: '1px solid #E0E0E0',
      }}
    >
      <Group justify="space-between" mb="xs">
        <Group>
          {service.icon_url && (
            <Image src={service.icon_url} alt={service.name} h={40} w={40} fit="contain" />
          )}
          <div>
            <Text fw={600}>{service.name}</Text>
            <Badge size="sm" variant="light" color="orange">
              {service.category}
            </Badge>
          </div>
        </Group>
        <Group gap="xs">
          <ActionIcon variant="light" color="orange" onClick={() => onEdit(service)}>
            <IconEdit size={16} />
          </ActionIcon>
          <ActionIcon variant="light" color="red" onClick={() => onDelete(service.id)}>
            <IconTrash size={16} />
          </ActionIcon>
        </Group>
      </Group>
    </Card>
  );
};


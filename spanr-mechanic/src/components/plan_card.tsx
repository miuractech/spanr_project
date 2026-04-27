import { Card, Group, Text, Badge, ActionIcon, Stack } from '@mantine/core';
import { IconEdit, IconTrash, IconClock, IconCoin } from '@tabler/icons-react';
import type { DbPlan } from '../types';

interface PlanCardProps {
  plan: DbPlan & { services?: { name: string } };
  onEdit: (plan: DbPlan) => void;
  onDelete: (planId: string) => void;
  onView: (planId: string) => void;
}

export const PlanCard: React.FC<PlanCardProps> = ({ plan, onEdit, onDelete, onView }) => {
  return (
    <Card 
      withBorder 
      shadow="sm" 
      padding="lg" 
      radius="md"
      style={{ 
        cursor: 'pointer',
        backgroundColor: '#FFFFFF',
        border: '1px solid #E0E0E0',
      }}
    >
      <div onClick={() => onView(plan.id)}>
        <Group justify="space-between" mb="xs">
          <Text fw={600} size="lg">{plan.name}</Text>
          <Group gap="xs" onClick={(e) => e.stopPropagation()}>
            <ActionIcon variant="light" color="orange" onClick={() => onEdit(plan)}>
              <IconEdit size={16} />
            </ActionIcon>
            <ActionIcon variant="light" color="red" onClick={() => onDelete(plan.id)}>
              <IconTrash size={16} />
            </ActionIcon>
          </Group>
        </Group>

        <Stack gap="xs">
          {plan.services && (
            <Text size="sm" c="dimmed">
              Service: {plan.services.name}
            </Text>
          )}
          
          <Group gap="xs">
            <Badge size="sm" variant="light" color="orange">
              {plan.vehicle_type}
            </Badge>
            <Badge size="sm" variant="light" color="orange">
              {plan.location_type}
            </Badge>
            {plan.badge && (
              <Badge size="sm" color="green">
                {plan.badge}
              </Badge>
            )}
          </Group>

          <Group gap="md">
            <Group gap={5}>
              <IconClock size={16} />
              <Text size="sm">{plan.duration} min</Text>
            </Group>
            <Group gap={5}>
              <IconCoin size={16} />
              <Text size="sm">₹{plan.base_price}</Text>
            </Group>
          </Group>

          {plan.warranty && (
            <Text size="xs" c="dimmed">
              Warranty: {plan.warranty}
            </Text>
          )}
        </Stack>
      </div>
    </Card>
  );
};


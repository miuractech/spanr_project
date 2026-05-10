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
      shadow="xs" 
      padding="lg" 
      radius="lg"
      style={{ 
        cursor: 'pointer',
        border: '1px solid #E0E0E0',
        transition: 'box-shadow 0.15s ease',
      }}
    >
      <div onClick={() => onView(plan.id)}>
        <Group justify="space-between" mb="xs">
          <Text fw={600} size="lg" c="#1C1C1C">{plan.name}</Text>
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
            <Text size="sm" c="#696969">
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

          <Group gap="md" pt={4} style={{ borderTop: '1px solid #F2F2F2' }}>
            <Group gap={5}>
              <IconClock size={16} color="#696969" />
              <Text size="sm" c="#696969">{plan.duration} min</Text>
            </Group>
            <Group gap={5}>
              <IconCoin size={16} color="#FC8019" />
              <Text size="sm" fw={600} c="#FC8019">₹{plan.base_price}</Text>
            </Group>
          </Group>

          {plan.warranty && (
            <Text size="xs" c="#696969">
              Warranty: {plan.warranty}
            </Text>
          )}
        </Stack>
      </div>
    </Card>
  );
};

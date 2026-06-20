import { Card, Group, Text, Badge, ActionIcon, Stack, Box } from '@mantine/core';
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
      padding="lg"
      radius="lg"
      withBorder
      style={{
        cursor: 'pointer',
        border: '1px solid #E0E0E0',
        borderTop: '3px solid #FC8019',
        height: '100%',
        display: 'flex',
        flexDirection: 'column',
        transition: 'box-shadow 0.2s ease, transform 0.15s ease',
      }}
      onMouseEnter={(e) => {
        e.currentTarget.style.boxShadow = '0 6px 20px rgba(252, 128, 25, 0.14)';
        e.currentTarget.style.transform = 'translateY(-2px)';
      }}
      onMouseLeave={(e) => {
        e.currentTarget.style.boxShadow = 'none';
        e.currentTarget.style.transform = 'translateY(0)';
      }}
    >
      <Box onClick={() => onView(plan.id)} style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
        <Group justify="space-between" align="flex-start" wrap="nowrap" mb="sm">
          <Text fw={700} size="lg" c="#1C1C1C" lineClamp={1} style={{ flex: 1, minWidth: 0 }}>
            {plan.name}
          </Text>
          <Group gap={4} onClick={(e) => e.stopPropagation()}>
            <ActionIcon variant="light" color="orange" size="sm" onClick={() => onEdit(plan)}>
              <IconEdit size={15} />
            </ActionIcon>
            <ActionIcon variant="light" color="red" size="sm" onClick={() => onDelete(plan.id)}>
              <IconTrash size={15} />
            </ActionIcon>
          </Group>
        </Group>

        <Stack gap="xs" style={{ flex: 1 }}>
          {plan.services && (
            <Text size="sm" c="#696969">
              Service: {plan.services.name}
            </Text>
          )}

          <Group gap={6}>
            <Badge size="sm" variant="light" color="orange">
              {plan.vehicle_type === 'car' ? 'Car' : 'Bike'}
            </Badge>
            <Badge size="sm" variant="light" color="gray">
              {plan.location_type.replace('_', ' ')}
            </Badge>
            {plan.badge && (
              <Badge size="sm" color="green" variant="light">
                {plan.badge}
              </Badge>
            )}
          </Group>

          {plan.warranty && (
            <Text size="xs" c="#696969">
              Warranty: {plan.warranty}
            </Text>
          )}
        </Stack>

        <Group
          gap="md"
          mt="md"
          pt="sm"
          wrap="nowrap"
          style={{ borderTop: '1px solid #F0F0F0' }}
        >
          <Group gap={6}>
            <IconClock size={18} color="#696969" />
            <Text size="sm" fw={600} c="#1C1C1C">
              {plan.duration} min
            </Text>
          </Group>
          <Group gap={6} ml="auto">
            <IconCoin size={18} color="#FC8019" />
            <Text size="md" fw={700} c="#FC8019">
              ₹{plan.base_price}
            </Text>
          </Group>
        </Group>
      </Box>
    </Card>
  );
};

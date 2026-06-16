import { Badge, Group, Text } from '@mantine/core';
import { IconUser } from '@tabler/icons-react';
import type { OrderAssignmentInfo } from '../orders/orders.types';

interface AssignmentBadgeProps {
  assignment?: OrderAssignmentInfo;
}

export const AssignmentBadge: React.FC<AssignmentBadgeProps> = ({ assignment }) => {
  if (!assignment) {
    return <Badge color="gray" variant="light">Unassigned</Badge>;
  }

  return (
    <Group gap={6}>
      <IconUser size={14} />
      <Text size="sm" fw={500}>{assignment.staff_name}</Text>
      <Badge color="blue" size="sm" variant="light">Assigned</Badge>
    </Group>
  );
};

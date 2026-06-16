import { Box, Group, Text, Button } from '@mantine/core';
import { IconPlus } from '@tabler/icons-react';
import type { ReactNode } from 'react';

interface PlanListSectionProps {
  title: string;
  addLabel: string;
  onAdd: () => void;
  children: ReactNode;
  emptyText?: string;
  isEmpty?: boolean;
}

export const PlanListSection: React.FC<PlanListSectionProps> = ({
  title,
  addLabel,
  onAdd,
  children,
  emptyText,
  isEmpty,
}) => (
  <Box>
    <Group justify="space-between" mb="sm">
      <Text size="sm" fw={600}>{title}</Text>
      <Button size="xs" variant="light" leftSection={<IconPlus size={14} />} onClick={onAdd}>
        {addLabel}
      </Button>
    </Group>
    {isEmpty && emptyText ? (
      <Text size="sm" c="dimmed" py="sm">{emptyText}</Text>
    ) : (
      children
    )}
  </Box>
);

export const planItemCardStyle: React.CSSProperties = {
  padding: 12,
  border: '1px solid #e9ecef',
  borderRadius: 8,
  backgroundColor: '#fafafa',
};

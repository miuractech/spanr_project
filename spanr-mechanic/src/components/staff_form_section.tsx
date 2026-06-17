import { Paper, Stack, Text } from '@mantine/core';

interface StaffFormSectionProps {
  title: string;
  description?: string;
  children: React.ReactNode;
}

export const StaffFormSection: React.FC<StaffFormSectionProps> = ({
  title,
  description,
  children,
}) => (
  <Paper withBorder p="md" radius="md" bg="#FAFAFA">
    <Stack gap="md">
      <div>
        <Text size="sm" fw={600} c="#1C1C1C">{title}</Text>
        {description && (
          <Text size="xs" c="dimmed" mt={4}>{description}</Text>
        )}
      </div>
      {children}
    </Stack>
  </Paper>
);

export const staffAddButtonProps = {
  color: 'orange' as const,
  variant: 'filled' as const,
  size: 'md' as const,
  miw: 96,
  h: 48,
  radius: 'md' as const,
};

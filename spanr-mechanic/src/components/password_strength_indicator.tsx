import { Progress, Stack, Text, List, ThemeIcon } from '@mantine/core';
import { IconCheck, IconX } from '@tabler/icons-react';
import { getPasswordStrength } from '../core/password.util';

interface PasswordStrengthIndicatorProps {
  password: string;
}

const CHECK_LABELS: { key: keyof ReturnType<typeof getPasswordStrength>['checks']; label: string }[] = [
  { key: 'minLength', label: 'At least 8 characters' },
  { key: 'hasUppercase', label: 'One uppercase letter' },
  { key: 'hasLowercase', label: 'One lowercase letter' },
  { key: 'hasNumber', label: 'One number' },
  { key: 'hasSpecial', label: 'One special character' },
];

export const PasswordStrengthIndicator: React.FC<PasswordStrengthIndicatorProps> = ({ password }) => {
  const result = getPasswordStrength(password);

  if (!password) return null;

  const progressValue = (result.score / 5) * 100;

  return (
    <Stack gap={6}>
      <Progress value={progressValue} color={result.color} size="sm" radius="xl" />
      <Text size="sm" c={result.color} fw={600}>
        Password strength: {result.label}
      </Text>
      <List spacing={4} size="sm" center>
        {CHECK_LABELS.map(({ key, label }) => {
          const passed = result.checks[key];
          return (
            <List.Item
              key={key}
              icon={
                <ThemeIcon color={passed ? 'green' : 'gray'} size={18} radius="xl" variant="light">
                  {passed ? <IconCheck size={12} /> : <IconX size={12} />}
                </ThemeIcon>
              }
            >
              <Text size="sm" c={passed ? 'dimmed' : 'gray.6'}>
                {label}
              </Text>
            </List.Item>
          );
        })}
      </List>
    </Stack>
  );
};

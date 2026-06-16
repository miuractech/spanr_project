import { Modal, Stack, Text, Group, Button, CopyButton, Alert, Code } from '@mantine/core';
import { IconCopy, IconCheck, IconAlertCircle } from '@tabler/icons-react';
import { formatPhoneDisplay } from '../core/phone.util';
import type { StaffCredentials } from '../staff/staff.service';

interface StaffCredentialsModalProps {
  opened: boolean;
  onClose: () => void;
  staffName: string;
  credentials: StaffCredentials | null;
  isReset?: boolean;
}

export const StaffCredentialsModal: React.FC<StaffCredentialsModalProps> = ({
  opened,
  onClose,
  staffName,
  credentials,
  isReset = false,
}) => {
  if (!credentials) return null;

  const loginInfo = `${formatPhoneDisplay(credentials.phone)}\nPassword: ${credentials.tempPassword}`;

  return (
    <Modal
      opened={opened}
      onClose={onClose}
      title={isReset ? 'Password Reset' : 'Employee Login Credentials'}
      size="md"
    >
      <Stack gap="md">
        <Alert icon={<IconAlertCircle size={16} />} color="orange" variant="light">
          Share these credentials with <strong>{staffName}</strong> via WhatsApp or in person.
          This password is shown only once. Employee must change it on first login.
        </Alert>

        <div>
          <Text size="sm" fw={500} mb={4}>Mobile (Login ID)</Text>
          <Code block>{formatPhoneDisplay(credentials.phone)}</Code>
        </div>

        <div>
          <Text size="sm" fw={500} mb={4}>Temporary Password</Text>
          <Code block>{credentials.tempPassword}</Code>
        </div>

        <Group justify="flex-end">
          <CopyButton value={loginInfo}>
            {({ copied, copy }) => (
              <Button
                color={copied ? 'green' : 'orange'}
                leftSection={copied ? <IconCheck size={16} /> : <IconCopy size={16} />}
                onClick={copy}
              >
                {copied ? 'Copied' : 'Copy credentials'}
              </Button>
            )}
          </CopyButton>
          <Button variant="subtle" onClick={onClose}>Done</Button>
        </Group>
      </Stack>
    </Modal>
  );
};

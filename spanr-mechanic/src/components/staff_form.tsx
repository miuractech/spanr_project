import { useState, useEffect } from 'react';
import {
  Modal,
  TextInput,
  Switch,
  Button,
  Stack,
  Group,
  MultiSelect,
} from '@mantine/core';
import type { StaffFormData } from '../staff/staff.service';
import type { StaffWithAccess } from '../staff/staff.service';

interface StaffFormProps {
  opened: boolean;
  onClose: () => void;
  onSubmit: (data: StaffFormData, permissions: string[]) => Promise<void>;
  initialData?: StaffWithAccess;
}

const availablePermissions = [
  { value: 'manage_services', label: 'Manage Services' },
  { value: 'manage_plans', label: 'Manage Plans' },
  { value: 'manage_orders', label: 'Manage Orders' },
  { value: 'manage_staff', label: 'Manage Staff' },
  { value: 'view_reports', label: 'View Reports' },
  { value: 'manage_company', label: 'Manage Company Profile' },
];

export const StaffForm: React.FC<StaffFormProps> = ({
  opened,
  onClose,
  onSubmit,
  initialData,
}) => {
  const [formData, setFormData] = useState<StaffFormData>({
    name: '',
    email: '',
    enabled: true,
  });

  const [permissions, setPermissions] = useState<string[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (initialData) {
      setFormData({
        name: initialData.name,
        email: initialData.email,
        enabled: initialData.enabled,
      });
      setPermissions(initialData.permissions);
    }
  }, [initialData]);

  const handleSubmit = async () => {
    setLoading(true);
    try {
      await onSubmit(formData, permissions);
      onClose();
      // Reset form
      setFormData({ name: '', email: '', enabled: true });
      setPermissions([]);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Modal
      opened={opened}
      onClose={onClose}
      title={initialData ? 'Edit Staff Member' : 'Add Staff Member'}
    >
      <Stack>
        <TextInput
          label="Name"
          placeholder="John Doe"
          required
          value={formData.name}
          onChange={(e) => setFormData({ ...formData, name: e.target.value })}
        />

        <TextInput
          label="Email"
          placeholder="john@example.com"
          type="email"
          required
          value={formData.email}
          onChange={(e) => setFormData({ ...formData, email: e.target.value })}
          disabled={!!initialData}
        />

        <Switch
          label="Enabled"
          checked={formData.enabled}
          onChange={(e) => setFormData({ ...formData, enabled: e.currentTarget.checked })}
        />

        <MultiSelect
          label="Permissions"
          placeholder="Select permissions"
          data={availablePermissions}
          value={permissions}
          onChange={setPermissions}
        />

        <Group justify="flex-end">
          <Button variant="subtle" onClick={onClose}>
            Cancel
          </Button>
          <Button onClick={handleSubmit} loading={loading}>
            {initialData ? 'Update' : 'Add'}
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
};


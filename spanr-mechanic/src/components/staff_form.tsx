import { useState, useEffect } from 'react';
import {
  Modal,
  TextInput,
  Switch,
  Button,
  Stack,
  Group,
  MultiSelect,
  NumberInput,
  Select,
  Text,
} from '@mantine/core';
import type { StaffFormData } from '../staff/staff.service';
import type { StaffWithAccess } from '../staff/staff.service';
import { StaffSkillsInput } from './staff_skills_input';
import { isStaffAuthEmail } from '../core/phone.util';

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
    enabled: true,
    phone: '',
    experienceYears: 0,
    availability: 'available',
    skills: [],
  });

  const [permissions, setPermissions] = useState<string[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (initialData) {
      setFormData({
        name: initialData.name,
        enabled: initialData.enabled,
        phone: initialData.phone ?? initialData.profile?.phone ?? '',
        experienceYears: initialData.profile?.experience_years ?? 0,
        availability: initialData.profile?.availability ?? 'available',
        skills: initialData.skills ?? [],
      });
      setPermissions(initialData.permissions);
    }
  }, [initialData]);

  const handleSubmit = async () => {
    if (!formData.phone.trim()) return;
    setLoading(true);
    try {
      await onSubmit(formData, permissions);
      onClose();
      setFormData({ name: '', enabled: true, phone: '', experienceYears: 0, availability: 'available', skills: [] });
      setPermissions([]);
    } finally {
      setLoading(false);
    }
  };

  const isMechanicAccount = !initialData || isStaffAuthEmail(initialData.email);

  return (
    <Modal
      opened={opened}
      onClose={onClose}
      title={initialData ? 'Edit Staff Member' : 'Add Mechanic Employee'}
      size="lg"
    >
      <Stack>
        {!initialData && (
          <Text size="sm" c="dimmed">
            A temporary password will be generated. Share the mobile number and password with the employee.
          </Text>
        )}

        <TextInput
          label="Name"
          placeholder="Rajesh Kumar"
          required
          value={formData.name}
          onChange={(e) => setFormData({ ...formData, name: e.target.value })}
        />

        <TextInput
          label="Mobile Number (Login ID)"
          placeholder="9876543210"
          required
          value={formData.phone}
          onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
          disabled={!!initialData && isMechanicAccount}
          description={initialData && isMechanicAccount ? 'Phone cannot be changed after account is created' : 'Employee uses this number to log into the mechanic app'}
        />

        <Group grow>
          <NumberInput
            label="Experience (years)"
            min={0}
            value={formData.experienceYears}
            onChange={(v) => setFormData({ ...formData, experienceYears: Number(v) || 0 })}
          />
          <Select
            label="Availability"
            data={[
              { value: 'available', label: 'Available' },
              { value: 'busy', label: 'Busy' },
              { value: 'off', label: 'Off' },
            ]}
            value={formData.availability}
            onChange={(v) => setFormData({ ...formData, availability: (v as StaffFormData['availability']) ?? 'available' })}
          />
        </Group>

        <StaffSkillsInput
          skills={formData.skills ?? []}
          onChange={(skills) => setFormData({ ...formData, skills })}
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
          <Button variant="subtle" onClick={onClose}>Cancel</Button>
          <Button onClick={handleSubmit} loading={loading} color="orange" disabled={!formData.name || !formData.phone}>
            {initialData ? 'Update' : 'Add & Generate Password'}
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
};

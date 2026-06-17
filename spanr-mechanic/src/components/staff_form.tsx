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
  FileInput,
  Avatar,
  ScrollArea,
  Divider,
} from '@mantine/core';
import { IconUpload, IconUser } from '@tabler/icons-react';
import type { StaffFormData, StaffCertificateInput, StaffCourseInput } from '../staff/staff.service';
import type { StaffWithAccess } from '../staff/staff.service';
import { StaffSkillsInput } from './staff_skills_input';
import { StaffCertificatesInput } from './staff_certificates_input';
import { StaffCoursesInput } from './staff_courses_input';
import { StaffFormSection } from './staff_form_section';
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

const emptyForm: StaffFormData = {
  name: '',
  enabled: true,
  phone: '',
  experienceYears: 0,
  availability: 'available',
  skills: [],
  certificates: [],
  courses: [],
};

export const StaffForm: React.FC<StaffFormProps> = ({
  opened,
  onClose,
  onSubmit,
  initialData,
}) => {
  const [formData, setFormData] = useState<StaffFormData>(emptyForm);
  const [photoFile, setPhotoFile] = useState<File | null>(null);
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
        certificates: (initialData.certificates ?? []).map((cert) => ({
          name: cert.name,
          fileUrl: cert.file_url,
          expiryDate: cert.expiry_date,
        })),
        courses: (initialData.courses ?? []).map((course) => ({
          courseName: course.course_name,
          institution: course.institution,
          completedDate: course.completed_date,
        })),
      });
      setPermissions(initialData.permissions);
      setPhotoFile(null);
    } else {
      setFormData(emptyForm);
      setPhotoFile(null);
      setPermissions([]);
    }
  }, [initialData, opened]);

  const handleSubmit = async () => {
    if (!formData.phone.trim()) return;
    setLoading(true);
    try {
      await onSubmit({ ...formData, photoFile }, permissions);
      onClose();
      setFormData(emptyForm);
      setPhotoFile(null);
      setPermissions([]);
    } finally {
      setLoading(false);
    }
  };

  const isMechanicAccount = !initialData || isStaffAuthEmail(initialData.email);
  const existingPhoto = initialData?.profile?.photo_url;
  const photoPreview = photoFile ? URL.createObjectURL(photoFile) : existingPhoto;

  return (
    <Modal
      opened={opened}
      onClose={onClose}
      title={initialData ? 'Edit Staff Member' : 'Add Mechanic Employee'}
      size="lg"
      scrollAreaComponent={ScrollArea.Autosize}
    >
      <Stack gap="lg">
        {!initialData && (
          <Text size="sm" c="dimmed">
            A temporary password will be generated. Share the mobile number and password with the employee.
          </Text>
        )}

        <StaffFormSection title="Basic Information">
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
            description={
              initialData && isMechanicAccount
                ? 'Phone cannot be changed after account is created'
                : 'Employee uses this number to log into the mechanic app'
            }
          />
          <Group align="flex-start" gap="md" wrap="nowrap">
            <Avatar
              src={photoPreview}
              size={88}
              radius="md"
              color="orange"
              variant="light"
            >
              {!photoPreview && <IconUser size={36} />}
            </Avatar>
            <FileInput
              label="Profile Picture"
              placeholder="Choose photo"
              accept="image/*"
              leftSection={<IconUpload size={18} />}
              leftSectionWidth={36}
              value={photoFile}
              onChange={setPhotoFile}
              clearable
              description="JPG or PNG, square photo works best"
              style={{ flex: 1 }}
            />
          </Group>
        </StaffFormSection>

        <StaffFormSection title="Work Details">
          <Group grow align="flex-start">
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
              onChange={(v) =>
                setFormData({
                  ...formData,
                  availability: (v as StaffFormData['availability']) ?? 'available',
                })
              }
            />
          </Group>
          <Switch
            label="Enabled"
            checked={formData.enabled}
            onChange={(e) => setFormData({ ...formData, enabled: e.currentTarget.checked })}
          />
        </StaffFormSection>

        <StaffFormSection
          title="Qualifications"
          description="Add skills, certificates, and completed courses for this mechanic."
        >
          <StaffSkillsInput
            skills={formData.skills ?? []}
            onChange={(skills) => setFormData({ ...formData, skills })}
          />
          <Divider />
          <StaffCertificatesInput
            certificates={formData.certificates ?? []}
            onChange={(certificates: StaffCertificateInput[]) =>
              setFormData({ ...formData, certificates })
            }
          />
          <Divider />
          <StaffCoursesInput
            courses={formData.courses ?? []}
            onChange={(courses: StaffCourseInput[]) => setFormData({ ...formData, courses })}
          />
        </StaffFormSection>

        <StaffFormSection title="Access">
          <MultiSelect
            label="Permissions"
            placeholder="Select permissions"
            data={availablePermissions}
            value={permissions}
            onChange={setPermissions}
          />
        </StaffFormSection>

        <Group justify="flex-end" mt="xs">
          <Button variant="subtle" onClick={onClose}>Cancel</Button>
          <Button
            onClick={handleSubmit}
            loading={loading}
            color="orange"
            disabled={!formData.name || !formData.phone}
          >
            {initialData ? 'Update' : 'Add & Generate Password'}
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
};

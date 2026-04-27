import { useState } from 'react';
import {
  TextInput,
  Button,
  Stack,
  Group,
  FileInput,
  Image,
  SimpleGrid,
  Textarea,
} from '@mantine/core';
import { IconUpload } from '@tabler/icons-react';
import type { CompanyFormData } from '../company/company.service';

interface CompanyProfileFormProps {
  initialData?: Partial<CompanyFormData>;
  onSubmit: (data: CompanyFormData, logoFile?: File) => Promise<void>;
  submitLabel?: string;
}

export const CompanyProfileForm: React.FC<CompanyProfileFormProps> = ({
  initialData,
  onSubmit,
  submitLabel = 'Save',
}) => {
  const [formData, setFormData] = useState<CompanyFormData>({
    companyName: initialData?.companyName || '',
    addressLine1: initialData?.addressLine1 || '',
    addressLine2: initialData?.addressLine2 || '',
    landmark: initialData?.landmark || '',
    city: initialData?.city || '',
    state: initialData?.state || '',
    phoneNumber: initialData?.phoneNumber || '',
    pincode: initialData?.pincode || '',
    phone: initialData?.phone || '',
    email: initialData?.email || '',
    logo: initialData?.logo || '',
  });

  const [logoFile, setLogoFile] = useState<File | null>(null);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      await onSubmit(formData, logoFile || undefined);
    } finally {
      setLoading(false);
    }
  };

  const updateField = (field: keyof CompanyFormData, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  return (
    <form onSubmit={handleSubmit}>
      <Stack gap="md">
        <TextInput
          label="Company Name"
          placeholder="Elite Auto Care"
          required
          value={formData.companyName}
          onChange={(e) => updateField('companyName', e.target.value)}
        />

        <SimpleGrid cols={2}>
          <TextInput
            label="Email"
            placeholder="contact@company.com"
            type="email"
            required
            value={formData.email}
            onChange={(e) => updateField('email', e.target.value)}
          />

          <TextInput
            label="Phone"
            placeholder="+91 98765 43210"
            required
            value={formData.phone}
            onChange={(e) => updateField('phone', e.target.value)}
          />
        </SimpleGrid>

        <TextInput
          label="Address Line 1"
          placeholder="123 Main Street"
          required
          value={formData.addressLine1}
          onChange={(e) => updateField('addressLine1', e.target.value)}
        />

        <TextInput
          label="Address Line 2"
          placeholder="Near XYZ Mall"
          value={formData.addressLine2}
          onChange={(e) => updateField('addressLine2', e.target.value)}
        />

        <TextInput
          label="Landmark"
          placeholder="Opposite ABC Bank"
          value={formData.landmark}
          onChange={(e) => updateField('landmark', e.target.value)}
        />

        <SimpleGrid cols={3}>
          <TextInput
            label="City"
            placeholder="Mumbai"
            required
            value={formData.city}
            onChange={(e) => updateField('city', e.target.value)}
          />

          <TextInput
            label="State"
            placeholder="Maharashtra"
            required
            value={formData.state}
            onChange={(e) => updateField('state', e.target.value)}
          />

          <TextInput
            label="Pincode"
            placeholder="400001"
            required
            value={formData.pincode}
            onChange={(e) => updateField('pincode', e.target.value)}
          />
        </SimpleGrid>

        <TextInput
          label="Phone Number"
          placeholder="+91 98765 43210"
          required
          value={formData.phoneNumber}
          onChange={(e) => updateField('phoneNumber', e.target.value)}
        />

        <FileInput
          label="Company Logo"
          placeholder="Upload logo"
          accept="image/*"
          leftSection={<IconUpload size={14} />}
          value={logoFile}
          onChange={setLogoFile}
        />

        {(formData.logo || logoFile) && (
          <Image
            src={logoFile ? URL.createObjectURL(logoFile) : formData.logo}
            alt="Company logo"
            h={100}
            w={100}
            fit="contain"
          />
        )}

        <Group justify="flex-end">
          <Button type="submit" loading={loading}>
            {submitLabel}
          </Button>
        </Group>
      </Stack>
    </form>
  );
};


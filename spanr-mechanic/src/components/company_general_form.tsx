import { useState } from 'react';
import { TextInput, Stack, SimpleGrid, Group, Badge, ActionIcon, Button, Text, Box, FileInput, Image, Paper } from '@mantine/core';
import type { UseFormReturnType } from '@mantine/form';
import { IconPlus, IconX, IconUpload } from '@tabler/icons-react';

interface GeneralFormData {
  companyName: string;
  email: string;
  phone: string;
  phoneNumber: string;
  certifications: string[];
  specializations: string[];
}

interface CompanyGeneralFormProps {
  form: UseFormReturnType<GeneralFormData>;
  userEmail?: string;
  existingLogo?: string;
  onLogoChange?: (file: File | null) => void;
}

export const CompanyGeneralForm: React.FC<CompanyGeneralFormProps> = ({
  form,
  userEmail,
  existingLogo,
  onLogoChange,
}) => {
  const [newCertification, setNewCertification] = useState('');
  const [newSpecialization, setNewSpecialization] = useState('');
  const [logoFile, setLogoFile] = useState<File | null>(null);

  const handleLogoChange = (file: File | null) => {
    setLogoFile(file);
    onLogoChange?.(file);
  };

  const handleAddCertification = () => {
    if (!newCertification.trim()) return;
    form.setFieldValue('certifications', [...form.values.certifications, newCertification.trim()]);
    setNewCertification('');
  };

  const handleRemoveCertification = (cert: string) => {
    form.setFieldValue('certifications', form.values.certifications.filter(c => c !== cert));
  };

  const handleAddSpecialization = () => {
    if (!newSpecialization.trim()) return;
    form.setFieldValue('specializations', [...form.values.specializations, newSpecialization.trim()]);
    setNewSpecialization('');
  };

  const handleRemoveSpecialization = (spec: string) => {
    form.setFieldValue('specializations', form.values.specializations.filter(s => s !== spec));
  };

  return (
    <Stack gap={32}>
      <Box>
        <Text size="lg" fw={600} mb={24}>Basic Information</Text>
        <Stack gap={20}>
          <TextInput
            label="Company Name"
            placeholder="Elite Auto Care"
            required
            size="md"
            {...form.getInputProps('companyName')}
            styles={{ input: { border: 'none', borderBottom: '1px solid #e9ecef', borderRadius: 0, paddingLeft: 0 } }}
          />

          <Box>
            <FileInput
              label="Company Logo"
              placeholder="Upload logo"
              accept="image/*"
              leftSection={<IconUpload size={16} />}
              value={logoFile}
              onChange={handleLogoChange}
              size="md"
              description="Upload your company logo"
            />
            {(existingLogo || logoFile) && (
              <Paper withBorder p="md" mt="md">
                <Text size="sm" fw={500} mb="xs">
                  {logoFile ? 'New Logo Preview' : 'Current Logo'}
                </Text>
                <Group>
                  <Image
                    src={logoFile ? URL.createObjectURL(logoFile) : existingLogo}
                    alt="Company logo"
                    h={100}
                    w={100}
                    fit="contain"
                  />
                  {logoFile && (
                    <ActionIcon
                      color="red"
                      size="sm"
                      onClick={() => handleLogoChange(null)}
                    >
                      <IconX size={16} />
                    </ActionIcon>
                  )}
                </Group>
              </Paper>
            )}
          </Box>

          <SimpleGrid cols={2} spacing={20}>
            <TextInput
              label="Email"
              placeholder="contact@company.com"
              type="email"
              required
              size="md"
              value={userEmail || form.values.email}
              disabled
              description="From your account"
              styles={{ input: { border: 'none', borderBottom: '1px solid #e9ecef', borderRadius: 0, paddingLeft: 0 } }}
            />

            <TextInput
              label="Primary Phone"
              placeholder="+91 98765 43210"
              required
              size="md"
              {...form.getInputProps('phone')}
              styles={{ input: { border: 'none', borderBottom: '1px solid #e9ecef', borderRadius: 0, paddingLeft: 0 } }}
            />
          </SimpleGrid>

          <TextInput
            label="Alternative Phone"
            placeholder="+91 98765 43210"
            required
            size="md"
            {...form.getInputProps('phoneNumber')}
            styles={{ input: { border: 'none', borderBottom: '1px solid #e9ecef', borderRadius: 0, paddingLeft: 0 } }}
          />
        </Stack>
      </Box>

      <Box>
        <Text size="lg" fw={600} mb={24}>Certifications</Text>
        <Stack gap={16}>
          <Group gap={8}>
            {form.values.certifications.map((cert) => (
              <Badge
                key={cert}
                size="lg"
                variant="light"
                rightSection={
                  <ActionIcon
                    size="xs"
                    color="gray"
                    radius="xl"
                    variant="transparent"
                    onClick={() => handleRemoveCertification(cert)}
                  >
                    <IconX size={12} />
                  </ActionIcon>
                }
              >
                {cert}
              </Badge>
            ))}
          </Group>
          <Group gap={12}>
            <TextInput
              placeholder="Add certification (e.g., ISO 9001)"
              value={newCertification}
              size="md"
              onChange={(e) => setNewCertification(e.target.value)}
              onKeyPress={(e) => e.key === 'Enter' && handleAddCertification()}
              style={{ flex: 1 }}
              styles={{ input: { border: 'none', borderBottom: '1px solid #e9ecef', borderRadius: 0, paddingLeft: 0 } }}
            />
            <Button 
              leftSection={<IconPlus size={16} />} 
              onClick={handleAddCertification}
              variant="light"
              size="md"
            >
              Add
            </Button>
          </Group>
        </Stack>
      </Box>

      <Box>
        <Text size="lg" fw={600} mb={24}>Specializations</Text>
        <Stack gap={16}>
          <Group gap={8}>
            {form.values.specializations.map((spec) => (
              <Badge
                key={spec}
                size="lg"
                variant="light"
                rightSection={
                  <ActionIcon
                    size="xs"
                    color="gray"
                    radius="xl"
                    variant="transparent"
                    onClick={() => handleRemoveSpecialization(spec)}
                  >
                    <IconX size={12} />
                  </ActionIcon>
                }
              >
                {spec}
              </Badge>
            ))}
          </Group>
          <Group gap={12}>
            <TextInput
              placeholder="Add specialization (e.g., Engine Repair)"
              value={newSpecialization}
              size="md"
              onChange={(e) => setNewSpecialization(e.target.value)}
              onKeyPress={(e) => e.key === 'Enter' && handleAddSpecialization()}
              style={{ flex: 1 }}
              styles={{ input: { border: 'none', borderBottom: '1px solid #e9ecef', borderRadius: 0, paddingLeft: 0 } }}
            />
            <Button 
              leftSection={<IconPlus size={16} />} 
              onClick={handleAddSpecialization}
              variant="light"
              size="md"
            >
              Add
            </Button>
          </Group>
        </Stack>
      </Box>
    </Stack>
  );
};


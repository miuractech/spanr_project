import { useState } from 'react';
import {
  TextInput,
  Stack,
  SimpleGrid,
  Group,
  Badge,
  ActionIcon,
  Button,
  Text,
  Box,
  FileInput,
  Image,
  Paper,
  MultiSelect,
} from '@mantine/core';
import type { UseFormReturnType } from '@mantine/form';
import { IconPlus, IconX, IconUpload } from '@tabler/icons-react';
import { CERTIFICATION_OPTIONS } from '../company/company.constants';

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

const addButtonProps = {
  color: 'orange' as const,
  variant: 'filled' as const,
  size: 'md' as const,
  miw: 112,
  h: 48,
  radius: 'md' as const,
};

export const CompanyGeneralForm: React.FC<CompanyGeneralFormProps> = ({
  form,
  userEmail,
  existingLogo,
  onLogoChange,
}) => {
  const [newSpecialization, setNewSpecialization] = useState('');
  const [logoFile, setLogoFile] = useState<File | null>(null);

  const handleLogoChange = (file: File | null) => {
    setLogoFile(file);
    onLogoChange?.(file);
  };

  const handleAddSpecialization = () => {
    if (!newSpecialization.trim()) return;
    form.setFieldValue('specializations', [
      ...form.values.specializations,
      newSpecialization.trim(),
    ]);
    setNewSpecialization('');
  };

  const handleRemoveSpecialization = (spec: string) => {
    form.setFieldValue(
      'specializations',
      form.values.specializations.filter((s) => s !== spec)
    );
  };

  return (
    <Stack gap={28} maw={680} w="100%">
      <Box>
        <Text size="lg" fw={600} c="#1C1C1C" mb="md">
          Basic information
        </Text>
        <Stack gap="md">
          <TextInput
            label="Company name"
            placeholder="Elite Auto Care"
            required
            {...form.getInputProps('companyName')}
          />

          <Box>
            <FileInput
              label="Company logo"
              placeholder="Choose image file"
              accept="image/*"
              leftSection={<IconUpload size={18} />}
              leftSectionWidth={36}
              value={logoFile}
              onChange={handleLogoChange}
              description="PNG or JPG, recommended square image"
              clearable
            />
            {(existingLogo || logoFile) && (
              <Paper withBorder p="md" mt="md" radius="md">
                <Text size="sm" fw={600} mb="xs" c="#1C1C1C">
                  {logoFile ? 'New logo preview' : 'Current logo'}
                </Text>
                <Group>
                  <Image
                    src={logoFile ? URL.createObjectURL(logoFile) : existingLogo}
                    alt="Company logo"
                    h={100}
                    w={100}
                    fit="contain"
                    radius="md"
                  />
                  {logoFile && (
                    <ActionIcon
                      color="red"
                      variant="light"
                      size="lg"
                      radius="md"
                      onClick={() => handleLogoChange(null)}
                      aria-label="Remove selected logo"
                    >
                      <IconX size={18} />
                    </ActionIcon>
                  )}
                </Group>
              </Paper>
            )}
          </Box>

          <SimpleGrid cols={{ base: 1, sm: 2 }} spacing="md">
            <TextInput
              label="Email"
              placeholder="contact@company.com"
              type="email"
              required
              value={userEmail || form.values.email}
              disabled
              // description="From your account"
            />

            <TextInput
              label="Primary phone"
              placeholder="+91 98765 43210"
              required
              {...form.getInputProps('phone')}
            />
          </SimpleGrid>

          <TextInput
            label="Alternative phone"
            placeholder="+91 98765 43210"
            required
            {...form.getInputProps('phoneNumber')}
          />
        </Stack>
      </Box>

      <Box>
        <Text size="lg" fw={600} c="#1C1C1C" mb="md">
          Certifications
        </Text>
        <MultiSelect
          label="Select certifications"
          placeholder="Choose certifications"
          data={CERTIFICATION_OPTIONS}
          value={form.values.certifications}
          onChange={(value) => form.setFieldValue('certifications', value)}
          searchable
          clearable
          nothingFoundMessage="No certification found"
        />
      </Box>

      <Box>
        <Text size="lg" fw={600} c="#1C1C1C" mb="md">
          Specializations
        </Text>
        <Stack gap="md">
          {form.values.specializations.length > 0 && (
            <Group gap="xs">
              {form.values.specializations.map((spec) => (
                <Badge
                  key={spec}
                  size="lg"
                  variant="light"
                  color="orange"
                  radius="md"
                  tt="none"
                  pr={6}
                  rightSection={
                    <ActionIcon
                      size="xs"
                      color="gray"
                      radius="xl"
                      variant="transparent"
                      onClick={() => handleRemoveSpecialization(spec)}
                      aria-label={`Remove ${spec}`}
                    >
                      <IconX size={12} />
                    </ActionIcon>
                  }
                >
                  {spec}
                </Badge>
              ))}
            </Group>
          )}
          <Group gap="sm" align="flex-end" wrap="nowrap">
            <TextInput
              style={{ flex: 1, minWidth: 0 }}
              placeholder="e.g. Engine repair"
              value={newSpecialization}
              onChange={(e) => setNewSpecialization(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === 'Enter') {
                  e.preventDefault();
                  handleAddSpecialization();
                }
              }}
            />
            <Button
              leftSection={<IconPlus size={18} />}
              onClick={handleAddSpecialization}
              {...addButtonProps}
            >
              Add
            </Button>
          </Group>
        </Stack>
      </Box>
    </Stack>
  );
};

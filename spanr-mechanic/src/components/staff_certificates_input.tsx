import { useState } from 'react';
import {
  Group,
  TextInput,
  Button,
  Stack,
  Text,
  FileInput,
  ActionIcon,
  Paper,
  ThemeIcon,
} from '@mantine/core';
import { IconPlus, IconX, IconUpload, IconCertificate } from '@tabler/icons-react';
import type { StaffCertificateInput } from '../staff/staff.service';
import { staffAddButtonProps } from './staff_form_section';

interface StaffCertificatesInputProps {
  certificates: StaffCertificateInput[];
  onChange: (certificates: StaffCertificateInput[]) => void;
}

export const StaffCertificatesInput: React.FC<StaffCertificatesInputProps> = ({
  certificates,
  onChange,
}) => {
  const [name, setName] = useState('');
  const [file, setFile] = useState<File | null>(null);
  const [expiryDate, setExpiryDate] = useState('');

  const addCertificate = () => {
    if (!name.trim() || !file) return;
    onChange([
      ...certificates,
      { name: name.trim(), file, expiryDate: expiryDate || undefined },
    ]);
    setName('');
    setFile(null);
    setExpiryDate('');
  };

  const removeCertificate = (index: number) => {
    onChange(certificates.filter((_, i) => i !== index));
  };

  return (
    <Stack gap="sm">
      <Group align="flex-end" gap="sm" wrap="nowrap">
        <TextInput
          label="Certificate name"
          placeholder="ASE Brake Systems"
          value={name}
          onChange={(e) => setName(e.target.value)}
          style={{ flex: 1 }}
        />
        <TextInput
          type="date"
          label="Expiry (optional)"
          value={expiryDate}
          onChange={(e) => setExpiryDate(e.target.value)}
          w={170}
        />
      </Group>
      <Group align="flex-end" gap="sm" wrap="nowrap">
        <FileInput
          label="Certificate file"
          placeholder="PDF or image"
          accept="image/*,application/pdf"
          leftSection={<IconUpload size={18} />}
          leftSectionWidth={36}
          value={file}
          onChange={setFile}
          clearable
          style={{ flex: 1 }}
        />
        <Button
          {...staffAddButtonProps}
          leftSection={<IconPlus size={16} />}
          onClick={addCertificate}
          disabled={!name.trim() || !file}
        >
          Add
        </Button>
      </Group>
      {certificates.length > 0 && (
        <Stack gap="xs">
          {certificates.map((cert, index) => (
            <Paper key={`${cert.name}-${index}`} withBorder p="sm" radius="md" bg="white">
              <Group justify="space-between" wrap="nowrap">
                <Group gap="sm" wrap="nowrap">
                  <ThemeIcon color="orange" variant="light" size="lg" radius="md">
                    <IconCertificate size={18} />
                  </ThemeIcon>
                  <div>
                    <Text size="sm" fw={600}>{cert.name}</Text>
                    <Text size="xs" c="dimmed">
                      {cert.file?.name ?? cert.fileUrl?.split('/').pop()}
                      {cert.expiryDate ? ` · Expires ${cert.expiryDate}` : ''}
                    </Text>
                  </div>
                </Group>
                <ActionIcon color="red" variant="subtle" onClick={() => removeCertificate(index)}>
                  <IconX size={16} />
                </ActionIcon>
              </Group>
            </Paper>
          ))}
        </Stack>
      )}
    </Stack>
  );
};

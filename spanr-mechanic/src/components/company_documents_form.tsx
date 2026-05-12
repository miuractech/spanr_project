import { useState } from 'react';
import {
  Stack,
  Text,
  Box,
  Group,
  Badge,
  ActionIcon,
  Paper,
  ThemeIcon,
  FileButton,
  Button,
  Anchor,
  Alert,
} from '@mantine/core';
import {
  IconUpload,
  IconX,
  IconFile,
  IconFileCheck,
  IconAlertCircle,
  IconExternalLink,
} from '@tabler/icons-react';

export interface DocumentFiles {
  gst?: File;
  pan?: File;
  utilityBill?: File;
}

export interface ExistingDocuments {
  gst?: string;
  pan?: string;
  utilityBill?: string;
}

interface DocumentSlotProps {
  label: string;
  description: string;
  hint: string;
  file?: File;
  existingUrl?: string;
  onFileChange: (file: File | null) => void;
}

const DocumentSlot: React.FC<DocumentSlotProps> = ({
  label,
  description,
  hint,
  file,
  existingUrl,
  onFileChange,
}) => {
  const hasFile = !!file || !!existingUrl;
  const displayName = file?.name || (existingUrl ? 'Uploaded document' : undefined);
  const isPdf = file
    ? file.type === 'application/pdf'
    : existingUrl?.toLowerCase().endsWith('.pdf');

  return (
    <Paper withBorder p="md" radius="lg" style={{ borderColor: '#E8E8E8' }}>
      <Group justify="space-between" mb={8} wrap="nowrap" align="flex-start">
        <Box style={{ flex: 1 }}>
          <Group gap="xs" mb={2}>
            <Text size="sm" fw={600}>
              {label}
            </Text>
            {hasFile && (
              <Badge size="xs" color="green" variant="light">
                Uploaded
              </Badge>
            )}
          </Group>
          <Text size="xs" c="dimmed" mb={4}>
            {description}
          </Text>
          <Text size="xs" c="orange.6">
            {hint}
          </Text>
        </Box>

        <ThemeIcon
          size="xl"
          variant="light"
          color={hasFile ? 'green' : 'gray'}
          radius="md"
        >
          {hasFile ? <IconFileCheck size={20} /> : <IconFile size={20} />}
        </ThemeIcon>
      </Group>

      {hasFile && (
        <Paper bg="gray.0" p="xs" radius="sm" mb="sm">
          <Group justify="space-between" wrap="nowrap">
            <Group gap="xs" style={{ flex: 1, minWidth: 0 }}>
              <IconFile size={14} color="gray" />
              <Text size="xs" truncate style={{ flex: 1 }}>
                {displayName}
              </Text>
              {existingUrl && !file && (
                <Anchor href={existingUrl} target="_blank" size="xs">
                  <IconExternalLink size={12} />
                </Anchor>
              )}
            </Group>
            <ActionIcon
              size="xs"
              color="red"
              variant="subtle"
              onClick={() => onFileChange(null)}
            >
              <IconX size={12} />
            </ActionIcon>
          </Group>
        </Paper>
      )}

      {!isPdf && file && (
        <Box mb="sm">
          <img
            src={URL.createObjectURL(file)}
            alt={label}
            style={{
              width: '100%',
              maxHeight: 120,
              objectFit: 'contain',
              borderRadius: 6,
              border: '1px solid #e9ecef',
            }}
          />
        </Box>
      )}

      <FileButton
        onChange={(f) => f && onFileChange(f)}
        accept="image/jpeg,image/png,image/webp,application/pdf"
      >
        {(props) => (
          <Button
            {...props}
            size="sm"
            radius="md"
            variant={hasFile ? 'light' : 'filled'}
            color="orange"
            leftSection={<IconUpload size={16} />}
            fullWidth
            h={40}
          >
            {hasFile ? 'Replace' : 'Upload'}
          </Button>
        )}
      </FileButton>
    </Paper>
  );
};

interface CompanyDocumentsFormProps {
  files: DocumentFiles;
  existingDocuments?: ExistingDocuments;
  onFilesChange: (files: DocumentFiles) => void;
}

export const CompanyDocumentsForm: React.FC<CompanyDocumentsFormProps> = ({
  files,
  existingDocuments,
  onFilesChange,
}) => {
  const [localFiles, setLocalFiles] = useState<DocumentFiles>(files);

  const update = (key: keyof DocumentFiles, file: File | null) => {
    const next = { ...localFiles, [key]: file ?? undefined };
    setLocalFiles(next);
    onFilesChange(next);
  };

  const uploadedCount = [
    localFiles.gst || existingDocuments?.gst,
    localFiles.pan || existingDocuments?.pan,
    localFiles.utilityBill || existingDocuments?.utilityBill,
  ].filter(Boolean).length;

  return (
    <Stack gap="lg" maw={680} w="100%">
      <Alert
        icon={<IconAlertCircle size={16} />}
        color="blue"
        variant="light"
        radius="md"
      >
        <Text size="sm" fw={500} mb={2}>
          Documents are used for verification only
        </Text>
        <Text size="xs" c="dimmed">
          Upload clear scans or photos (JPEG, PNG, PDF). All documents are kept
          private and reviewed by the SPANR team.
        </Text>
      </Alert>

      <Box>
        <Group justify="space-between" mb={16}>
          <Text size="lg" fw={600}>
            Business Documents
          </Text>
          <Badge variant="light" color={uploadedCount === 3 ? 'green' : 'gray'}>
            {uploadedCount}/3 uploaded
          </Badge>
        </Group>

        <Stack gap={12}>
          <DocumentSlot
            label="GST Certificate"
            description="Certificate of GST registration issued by the Government of India."
            hint="GSTIN registration certificate — required for invoicing"
            file={localFiles.gst}
            existingUrl={existingDocuments?.gst}
            onFileChange={(f) => update('gst', f)}
          />

          <DocumentSlot
            label="Company PAN Card"
            description="Permanent Account Number card for your registered business entity."
            hint="Business PAN (not personal) — required for tax compliance"
            file={localFiles.pan}
            existingUrl={existingDocuments?.pan}
            onFileChange={(f) => update('pan', f)}
          />

          <DocumentSlot
            label="Utility Bill"
            description="Recent electricity, water, or gas bill for your registered business address."
            hint="Must be within the last 3 months — used for address verification"
            file={localFiles.utilityBill}
            existingUrl={existingDocuments?.utilityBill}
            onFileChange={(f) => update('utilityBill', f)}
          />
        </Stack>
      </Box>

      {uploadedCount < 3 && (
        <Text size="xs" c="dimmed" ta="center">
          You can skip this step and upload documents later from your company profile. Verification may be required to activate your account.
        </Text>
      )}
    </Stack>
  );
};

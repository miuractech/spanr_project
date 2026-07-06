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
  Divider,
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
  // Mandatory KYC
  aadhaarFront?: File;
  aadhaarBack?: File;
  personalPan?: File;
  bankPassbook?: File;
  homeAddressProof?: File;
  homeUtilityBill?: File;
  shopUtilityBill?: File;
  // Optional
  gstCertificate?: File;
  firmPan?: File;
  firmRegistration?: File;
}

export interface ExistingDocuments {
  aadhaarFront?: string;
  aadhaarBack?: string;
  personalPan?: string;
  bankPassbook?: string;
  homeAddressProof?: string;
  homeUtilityBill?: string;
  shopUtilityBill?: string;
  gstCertificate?: string;
  firmPan?: string;
  firmRegistration?: string;
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

const MANDATORY_KEYS: (keyof DocumentFiles)[] = [
  'aadhaarFront',
  'aadhaarBack',
  'personalPan',
  'bankPassbook',
  'homeAddressProof',
  'homeUtilityBill',
  'shopUtilityBill',
];

const MANDATORY_SLOTS: Array<{
  key: keyof DocumentFiles;
  label: string;
  description: string;
  hint: string;
}> = [
  {
    key: 'aadhaarFront',
    label: 'Aadhaar Card — Front',
    description: 'Front side of your Aadhaar card (12-digit UID visible).',
    hint: 'Government photo ID — required for identity verification',
  },
  {
    key: 'aadhaarBack',
    label: 'Aadhaar Card — Back',
    description: 'Back side of your Aadhaar card (address side).',
    hint: 'Back side required for address verification',
  },
  {
    key: 'personalPan',
    label: 'Personal PAN Card',
    description: 'Your individual PAN card (not business PAN).',
    hint: 'Required for tax identity verification',
  },
  {
    key: 'bankPassbook',
    label: 'Bank Passbook / Cancelled Cheque',
    description:
      'First page of your bank passbook or a cancelled cheque showing account details.',
    hint: 'Required for payment disbursement setup',
  },
  {
    key: 'homeAddressProof',
    label: 'Home Address Proof',
    description:
      'Document proving your residential address (Aadhaar, voter ID, etc.).',
    hint: 'Must show your current home address',
  },
  {
    key: 'homeUtilityBill',
    label: 'Home Utility Bill',
    description:
      'Recent electricity, water, or gas bill for your home address.',
    hint: 'Must be within the last 3 months',
  },
  {
    key: 'shopUtilityBill',
    label: 'Shop / Garage Utility Bill',
    description:
      'Recent electricity or water bill for your shop/garage address.',
    hint: 'Must be within the last 3 months — used for shop address verification',
  },
];

const OPTIONAL_SLOTS: Array<{
  key: keyof DocumentFiles;
  label: string;
  description: string;
  hint: string;
}> = [
  {
    key: 'gstCertificate',
    label: 'GST Certificate',
    description: 'Certificate of GST registration (if registered).',
    hint: 'Optional — upload if you have a GSTIN',
  },
  {
    key: 'firmPan',
    label: 'Firm / Business PAN',
    description:
      'PAN card for your registered business entity (if applicable).',
    hint: 'Optional — required only for registered firms',
  },
  {
    key: 'firmRegistration',
    label: 'Firm Registration Certificate',
    description: 'Certificate of incorporation or firm registration document.',
    hint: 'Optional — required only for registered businesses',
  },
];

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

  const mandatoryUploaded = MANDATORY_KEYS.filter(
    (k) => localFiles[k] || existingDocuments?.[k]
  ).length;

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
            Mandatory Documents
          </Text>
          <Badge
            variant="light"
            color={mandatoryUploaded === MANDATORY_KEYS.length ? 'green' : 'orange'}
          >
            {mandatoryUploaded}/{MANDATORY_KEYS.length} uploaded
          </Badge>
        </Group>
        <Stack gap={12}>
          {MANDATORY_SLOTS.map((slot) => (
            <DocumentSlot
              key={slot.key}
              label={slot.label}
              description={slot.description}
              hint={slot.hint}
              file={localFiles[slot.key]}
              existingUrl={existingDocuments?.[slot.key]}
              onFileChange={(f) => update(slot.key, f)}
            />
          ))}
        </Stack>
      </Box>

      <Divider label="Optional Documents" labelPosition="left" />

      <Box>
        <Text size="sm" c="dimmed" mb={12}>
          Upload if applicable. These help with faster verification for
          registered businesses.
        </Text>
        <Stack gap={12}>
          {OPTIONAL_SLOTS.map((slot) => (
            <DocumentSlot
              key={slot.key}
              label={slot.label}
              description={slot.description}
              hint={slot.hint}
              file={localFiles[slot.key]}
              existingUrl={existingDocuments?.[slot.key]}
              onFileChange={(f) => update(slot.key, f)}
            />
          ))}
        </Stack>
      </Box>

      {mandatoryUploaded < MANDATORY_KEYS.length && (
        <Text size="xs" c="dimmed" ta="center">
          You can skip and upload documents later from your shop profile.
          Verification may be required to activate your account.
        </Text>
      )}
    </Stack>
  );
};

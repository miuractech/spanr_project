import { useState, useRef } from 'react';
import { Stepper, Button, Group, Box, Alert, Text } from '@mantine/core';
import { useForm } from '@mantine/form';
import {
  IconAlertCircle,
  IconArrowLeft,
  IconArrowRight,
  IconCheck,
} from '@tabler/icons-react';
import { CompanyGeneralForm } from './company_general_form';
import { CompanyLocationForm } from './company_location_form';
import { CompanyImagesForm } from './company_images_form';
import { CompanyDocumentsForm } from './company_documents_form';
import type { DocumentFiles } from './company_documents_form';
import type { CompanyFormData } from '../company/company.service';

const TOTAL_STEPS = 4;

interface CompanyProfileStepperProps {
  initialData?: Partial<CompanyFormData>;
  onSubmit: (
    data: CompanyFormData,
    logoFile?: File,
    imageFiles?: File[],
    certifications?: string[],
    specializations?: string[],
    documents?: DocumentFiles
  ) => Promise<void>;
  submitLabel?: string;
  /** Phone number from auth — pre-fills primary phone, shown as read-only */
  userPhone?: string;
  initialCertifications?: string[];
  initialSpecializations?: string[];
  /** When false (default for onboarding), steps can only be navigated via Back/Next buttons. */
  allowFreeNavigation?: boolean;
}

export const CompanyProfileStepper: React.FC<CompanyProfileStepperProps> = ({
  initialData,
  onSubmit,
  submitLabel = 'Save',
  userPhone,
  initialCertifications = [],
  initialSpecializations = [],
  allowFreeNavigation = true,
}) => {
  const [active, setActive] = useState(0);
  const [loading, setLoading] = useState(false);
  const submitInFlight = useRef(false);
  const [stepError, setStepError] = useState<string>('');

  const generalForm = useForm({
    initialValues: {
      companyName: initialData?.companyName || '',
      phoneNumber: initialData?.phoneNumber || '',
      certifications: initialCertifications,
      specializations: initialSpecializations,
    },
    validate: {
      companyName: (v) =>
        v.trim().length >= 2
          ? null
          : 'Shop name must be at least 2 characters',
    },
  });

  const locationForm = useForm({
    initialValues: {
      addressLine1: initialData?.addressLine1 || '',
      addressLine2: initialData?.addressLine2 || '',
      landmark: initialData?.landmark || '',
      city: initialData?.city || '',
      state: initialData?.state || '',
      pincode: initialData?.pincode || '',
      latitude: initialData?.latitude ?? null,
      longitude: initialData?.longitude ?? null,
    },
    validate: {
      addressLine1: (v) => (v.trim() ? null : 'Address is required'),
      city: (v) => (v.trim() ? null : 'City is required'),
      state: (v) => (v.trim() ? null : 'State is required'),
      pincode: (v) =>
        /^[0-9]{6}$/.test(v) ? null : 'Enter a valid 6-digit pincode',
    },
  });

  const [logoFile, setLogoFile] = useState<File | null>(null);
  const [imageFiles, setImageFiles] = useState<File[]>([]);
  const [existingImages, setExistingImages] = useState<string[]>(
    initialData?.images || []
  );
  const [documentFiles, setDocumentFiles] = useState<DocumentFiles>({});

  const validateCurrentStep = (): boolean => {
    setStepError('');
    if (active === 0) {
      const validation = generalForm.validate();
      if (validation.hasErrors) {
        const errors = Object.values(validation.errors);
        setStepError(
          errors.length > 0
            ? String(errors[0])
            : 'Please fix the errors in the form'
        );
        return false;
      }
    } else if (active === 1) {
      const validation = locationForm.validate();
      if (validation.hasErrors) {
        const errors = Object.values(validation.errors);
        setStepError(
          errors.length > 0
            ? String(errors[0])
            : 'Please fix the errors in the form'
        );
        return false;
      }
    }
    return true;
  };

  const nextStep = () => {
    if (validateCurrentStep()) {
      setStepError('');
      setActive((c) => Math.min(c + 1, TOTAL_STEPS - 1));
    }
  };

  const prevStep = () => {
    setStepError('');
    setActive((c) => Math.max(c - 1, 0));
  };

  const handleSubmit = async () => {
    const generalValid = !generalForm.validate().hasErrors;
    const locationValid = !locationForm.validate().hasErrors;

    if (!generalValid) {
      setStepError('Please complete step 1 correctly');
      setActive(0);
      return;
    }
    if (!locationValid) {
      setStepError('Please complete step 2 correctly');
      setActive(1);
      return;
    }

    if (submitInFlight.current || loading) return;
    submitInFlight.current = true;
    setLoading(true);

    try {
      setStepError('');
      const formData: CompanyFormData = {
        companyName: generalForm.values.companyName,
        email: userPhone
          ? `${userPhone.replace(/\D/g, '')}@spanr.owner`
          : '',
        phone: userPhone || '',
        phoneNumber: generalForm.values.phoneNumber || '',
        addressLine1: locationForm.values.addressLine1,
        addressLine2: locationForm.values.addressLine2 || '',
        landmark: locationForm.values.landmark || '',
        city: locationForm.values.city,
        state: locationForm.values.state,
        pincode: locationForm.values.pincode,
        latitude: locationForm.values.latitude ?? undefined,
        longitude: locationForm.values.longitude ?? undefined,
        images: existingImages,
      };

      await onSubmit(
        formData,
        logoFile || undefined,
        imageFiles,
        generalForm.values.certifications,
        generalForm.values.specializations,
        documentFiles
      );
    } catch (error) {
      setStepError(
        error instanceof Error ? error.message : 'Failed to submit form'
      );
    } finally {
      submitInFlight.current = false;
      setLoading(false);
    }
  };

  return (
    <Box>
      {stepError && (
        <Alert icon={<IconAlertCircle size={16} />} color="red" mb={24}>
          {stepError}
        </Alert>
      )}

      <Stepper
        active={active}
        onStepClick={
          allowFreeNavigation
            ? (step) => {
                setStepError('');
                setActive(step);
              }
            : undefined
        }
        allowNextStepsSelect={allowFreeNavigation}
        mb={40}
        styles={{
          step: { padding: 0 },
          stepBody: { marginTop: 10 },
          stepLabel: { fontWeight: 600, fontSize: 14 },
          stepDescription: { fontSize: 12, marginTop: 4 },
        }}
      >
        <Stepper.Step label="Shop Info" description="Shop details">
          <Box pt={24}>
            <CompanyGeneralForm
              form={generalForm}
              primaryPhone={userPhone}
              existingLogo={initialData?.logo}
              onLogoChange={setLogoFile}
            />
          </Box>
        </Stepper.Step>

        <Stepper.Step label="Location" description="Address & map">
          <Box pt={24}>
            <CompanyLocationForm form={locationForm} />
          </Box>
        </Stepper.Step>

        <Stepper.Step label="Photos" description="Shop images">
          <Box pt={24}>
            <CompanyImagesForm
              existingImages={existingImages}
              onImagesChange={setImageFiles}
              onRemoveExisting={(url) =>
                setExistingImages((p) => p.filter((u) => u !== url))
              }
            />
          </Box>
        </Stepper.Step>

        <Stepper.Step label="Documents" description="KYC verification">
          <Box pt={24}>
            <CompanyDocumentsForm
              files={documentFiles}
              onFilesChange={setDocumentFiles}
            />
          </Box>
        </Stepper.Step>
      </Stepper>

      <Group justify="space-between" mt={48}>
        <Button
          variant="subtle"
          color="gray"
          onClick={prevStep}
          disabled={active === 0}
          size="md"
          leftSection={<IconArrowLeft size={16} />}
        >
          Back
        </Button>

        <Group gap="xs">
          <Text size="xs" c="dimmed">
            Step {active + 1} of {TOTAL_STEPS}
          </Text>
          {active < TOTAL_STEPS - 1 ? (
            <Button
              onClick={nextStep}
              size="md"
              color="orange"
              rightSection={<IconArrowRight size={16} />}
            >
              Next
            </Button>
          ) : (
            <Button
              onClick={handleSubmit}
              loading={loading}
              size="md"
              color="orange"
              leftSection={<IconCheck size={16} />}
            >
              {submitLabel}
            </Button>
          )}
        </Group>
      </Group>
    </Box>
  );
};

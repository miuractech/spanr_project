import { useState } from 'react';
import { Stepper, Button, Group, Box, Alert, Text } from '@mantine/core';
import { useForm, yupResolver } from '@mantine/form';
import * as yup from 'yup';
import { IconAlertCircle, IconArrowLeft, IconArrowRight, IconCheck } from '@tabler/icons-react';
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
  userEmail?: string;
  initialCertifications?: string[];
  initialSpecializations?: string[];
  /** When false (default for onboarding), steps can only be navigated via Back/Next buttons. */
  allowFreeNavigation?: boolean;
}

const generalSchema = yup.object({
  companyName: yup.string().required('Company name is required').min(2, 'Company name must be at least 2 characters'),
  email: yup.string().required('Email is required').email('Invalid email format'),
  phone: yup.string().required('Primary phone is required').min(10, 'Phone must be at least 10 digits'),
  phoneNumber: yup.string().required('Alternative phone is required').min(10, 'Phone must be at least 10 digits'),
  certifications: yup.array().of(yup.string()).default([]),
  specializations: yup.array().of(yup.string()).default([]),
});

const locationSchema = yup.object({
  addressLine1: yup.string().required('Address Line 1 is required'),
  addressLine2: yup.string(),
  landmark: yup.string(),
  city: yup.string().required('City is required'),
  state: yup.string().required('State is required'),
  pincode: yup.string().required('Pincode is required').matches(/^[0-9]{6}$/, 'Pincode must be 6 digits'),
  latitude: yup.number().nullable().min(-90, 'Latitude must be between -90 and 90').max(90, 'Latitude must be between -90 and 90'),
  longitude: yup.number().nullable().min(-180, 'Longitude must be between -180 and 180').max(180, 'Longitude must be between -180 and 180'),
});

export const CompanyProfileStepper: React.FC<CompanyProfileStepperProps> = ({
  initialData,
  onSubmit,
  submitLabel = 'Save',
  userEmail,
  initialCertifications = [],
  initialSpecializations = [],
  allowFreeNavigation = true,
}) => {
  const [active, setActive] = useState(0);
  const [loading, setLoading] = useState(false);
  const [stepError, setStepError] = useState<string>('');

  const generalForm = useForm({
    initialValues: {
      companyName: initialData?.companyName || '',
      email: userEmail || initialData?.email || '',
      phone: initialData?.phone || '',
      phoneNumber: initialData?.phoneNumber || '',
      certifications: initialCertifications,
      specializations: initialSpecializations,
    },
    validate: yupResolver(generalSchema),
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
    validate: yupResolver(locationSchema),
  });

  const [logoFile, setLogoFile] = useState<File | null>(null);
  const [imageFiles, setImageFiles] = useState<File[]>([]);
  const [existingImages, setExistingImages] = useState<string[]>(initialData?.images || []);
  const [documentFiles, setDocumentFiles] = useState<DocumentFiles>({});

  const validateCurrentStep = async (): Promise<boolean> => {
    setStepError('');
    if (active === 0) {
      const validation = generalForm.validate();
      if (validation.hasErrors) {
        const errors = Object.values(validation.errors);
        setStepError(errors.length > 0 ? String(errors[0]) : 'Please fix the errors in the form');
        return false;
      }
    } else if (active === 1) {
      const validation = locationForm.validate();
      if (validation.hasErrors) {
        const errors = Object.values(validation.errors);
        setStepError(errors.length > 0 ? String(errors[0]) : 'Please fix the errors in the form');
        return false;
      }
    }
    return true;
  };

  const nextStep = async () => {
    const isValid = await validateCurrentStep();
    if (isValid) {
      setStepError('');
      setActive((current) => (current < TOTAL_STEPS - 1 ? current + 1 : current));
    }
  };

  const prevStep = () => {
    setStepError('');
    setActive((current) => (current > 0 ? current - 1 : current));
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

    setLoading(true);
    try {
      setStepError('');
      const formData: CompanyFormData = {
        companyName: generalForm.values.companyName,
        email: userEmail || generalForm.values.email,
        phone: generalForm.values.phone,
        phoneNumber: generalForm.values.phoneNumber,
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
      setStepError(error instanceof Error ? error.message : 'Failed to submit form');
      throw error;
    } finally {
      setLoading(false);
    }
  };

  const removeExistingImage = (imageUrl: string) => {
    setExistingImages((prev) => prev.filter((url) => url !== imageUrl));
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
        mb={48}
        styles={{
          step: { padding: 0 },
          stepBody: { marginTop: 8 },
        }}
      >
        <Stepper.Step label="General Info" description="Company details">
          <Box pt={32}>
            <CompanyGeneralForm
              form={generalForm}
              userEmail={userEmail}
              existingLogo={initialData?.logo}
              onLogoChange={setLogoFile}
            />
          </Box>
        </Stepper.Step>

        <Stepper.Step label="Location" description="Address & map">
          <Box pt={32}>
            <CompanyLocationForm form={locationForm} />
          </Box>
        </Stepper.Step>

        <Stepper.Step label="Photos" description="Shop images">
          <Box pt={32}>
            <CompanyImagesForm
              existingImages={existingImages}
              onImagesChange={setImageFiles}
              onRemoveExisting={removeExistingImage}
            />
          </Box>
        </Stepper.Step>

        <Stepper.Step label="Documents" description="KYC verification">
          <Box pt={32}>
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

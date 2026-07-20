import { useState, useEffect } from 'react';
import { Modal, Stack, Button, Group, Tabs, Box, LoadingOverlay } from '@mantine/core';
import { PlanBasicInfo } from './plan_form/plan_basic_info';
import { PlanFuelTypes } from './plan_form/plan_fuel_types';
import { PlanFeaturesList } from './plan_form/plan_features_list';
import { PlanFaqsList } from './plan_form/plan_faqs_list';
import { PlanOutcomesList } from './plan_form/plan_outcomes_list';
import { PlanAdditionalServices } from './plan_form/plan_additional_services';
import { PlanStepsList } from './plan_form/plan_steps_list';
import { plansService } from '../plans/plans.service';
import type { PlanFormData } from '../plans/plans.service';
import type { PlanDetails } from '../plans/plans.service';

interface PlanFormProps {
  opened: boolean;
  onClose: () => void;
  onSubmit: (data: PlanFormData) => Promise<void>;
  services: Array<{ id: string; name: string }>;
  initialData?: PlanDetails;
  defaultServiceId?: string;
  detailsLoading?: boolean;
}

const emptyFormData = (defaultServiceId?: string): PlanFormData => ({
  serviceId: defaultServiceId || '',
  name: '',
  vehicleType: 'bike',
  locationType: 'in_premise',
  duration: 60,
  basePrice: 0,
  tax: 18,
  warranty: '',
  guarantee: '',
  badge: '',
  planType: 'package',
  packageTier: undefined,
  fuelTypes: [],
  features: [],
  faqs: [],
  serviceOutcomes: [],
  additionalServices: [],
  steps: [],
});

export const PlanForm: React.FC<PlanFormProps> = ({
  opened,
  onClose,
  onSubmit,
  services,
  initialData,
  defaultServiceId,
  detailsLoading = false,
}) => {
  const [formData, setFormData] = useState<PlanFormData>(emptyFormData(defaultServiceId));
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (!opened) return;
    if (initialData) {
      setFormData({
        serviceId: initialData.service_id,
        name: initialData.name,
        vehicleType: initialData.vehicle_type,
        locationType: initialData.location_type,
        duration: initialData.duration,
        basePrice: Number(initialData.base_price),
        tax: Number(initialData.tax),
        warranty: initialData.warranty || '',
        guarantee: initialData.guarantee || '',
        badge: initialData.badge || '',
        planType: (initialData as any).plan_type || 'package',
        packageTier: (initialData as any).package_tier || undefined,
        fuelTypes: (initialData.fuelTypes?.filter((f): f is 'diesel' | 'petrol' => f === 'diesel' || f === 'petrol')) || [],
        features: initialData.features?.map(f => ({
          feature: f.feature,
          displayOrder: f.display_order,
        })) || [],
        faqs: initialData.faqs?.map(f => ({
          question: f.question,
          answer: f.answer,
          displayOrder: f.display_order,
        })) || [],
        serviceOutcomes: initialData.serviceOutcomes?.map(o => ({
          title: o.title,
          imageUrl: o.image_url,
          description: o.description,
          displayOrder: o.display_order,
        })) || [],
        additionalServices: initialData.additionalServices?.map(a => ({
          serviceName: a.service_name,
          displayOrder: a.display_order,
        })) || [],
        steps: initialData.steps?.map(s => ({
          stepDescription: s.step_description,
          displayOrder: s.display_order,
        })) || [],
      });
    } else {
      setFormData(emptyFormData(defaultServiceId));
    }
  }, [initialData, defaultServiceId, opened]);

  const handleFieldChange = (field: string, value: unknown) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  const handleSubmit = async () => {
    setSaving(true);
    try {
      const updatedOutcomes = await Promise.all(
        formData.serviceOutcomes.map(async (outcome) => {
          const imageFile = (outcome as { imageFile?: File }).imageFile;
          if (imageFile) {
            const imageUrl = await plansService.uploadOutcomeImage(
              imageFile,
              initialData?.id || 'temp',
            );
            return { ...outcome, imageUrl };
          }
          return outcome;
        }),
      );

      await onSubmit({ ...formData, serviceOutcomes: updatedOutcomes });
      onClose();
      setFormData(emptyFormData(defaultServiceId));
    } finally {
      setSaving(false);
    }
  };

  const isBusy = saving || detailsLoading;

  return (
    <Modal
      opened={opened}
      onClose={onClose}
      title={initialData ? 'Edit Plan' : 'Create Plan'}
      size="xl"
      closeOnClickOutside={!isBusy}
      closeOnEscape={!isBusy}
      styles={{
        body: { paddingBottom: 0 },
      }}
    >
      <Box pos="relative" mih={detailsLoading ? 280 : undefined}>
        <LoadingOverlay
          visible={detailsLoading}
          zIndex={200}
          overlayProps={{ blur: 1 }}
          loaderProps={{ type: 'dots' }}
        />

        <Box
          style={{ maxHeight: '60vh', overflowY: 'auto', paddingRight: 4 }}
          opacity={detailsLoading ? 0.4 : 1}
        >
          <Tabs defaultValue="basic" keepMounted={false}>
            <Tabs.List>
              <Tabs.Tab value="basic">Basic Info</Tabs.Tab>
              <Tabs.Tab value="details">Details</Tabs.Tab>
              <Tabs.Tab value="faqs">FAQs</Tabs.Tab>
              <Tabs.Tab value="outcomes">Outcomes</Tabs.Tab>
            </Tabs.List>

            <Tabs.Panel value="basic" pt="md">
              <Stack gap="md">
                <PlanBasicInfo
                  formData={formData}
                  services={services}
                  onChange={handleFieldChange}
                />
                <PlanFuelTypes
                  selectedFuelTypes={formData.fuelTypes}
                  onChange={(fuelTypes) => handleFieldChange('fuelTypes', fuelTypes)}
                />
              </Stack>
            </Tabs.Panel>

            <Tabs.Panel value="details" pt="md">
              <Stack gap="lg">
                <PlanFeaturesList
                  features={formData.features}
                  onChange={(features) => handleFieldChange('features', features)}
                  disabled={isBusy}
                />
                <PlanAdditionalServices
                  services={formData.additionalServices}
                  onChange={(services) => handleFieldChange('additionalServices', services)}
                  disabled={isBusy}
                />
                <PlanStepsList
                  steps={formData.steps}
                  onChange={(steps) => handleFieldChange('steps', steps)}
                  disabled={isBusy}
                />
              </Stack>
            </Tabs.Panel>

            <Tabs.Panel value="faqs" pt="md">
              <PlanFaqsList
                faqs={formData.faqs}
                onChange={(faqs) => handleFieldChange('faqs', faqs)}
                disabled={isBusy}
              />
            </Tabs.Panel>

            <Tabs.Panel value="outcomes" pt="md">
              <PlanOutcomesList
                outcomes={formData.serviceOutcomes}
                onChange={(outcomes) => handleFieldChange('serviceOutcomes', outcomes)}
                disabled={isBusy}
              />
            </Tabs.Panel>
          </Tabs>
        </Box>

        <Group
          justify="flex-end"
          gap="sm"
          py="md"
          mt="md"
          style={{ borderTop: '1px solid #e9ecef' }}
        >
          <Button variant="subtle" onClick={onClose} disabled={saving}>
            Cancel
          </Button>
          <Button onClick={handleSubmit} loading={saving} disabled={detailsLoading}>
            {initialData ? 'Update' : 'Create'}
          </Button>
        </Group>
      </Box>
    </Modal>
  );
};

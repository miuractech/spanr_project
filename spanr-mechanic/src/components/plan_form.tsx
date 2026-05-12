import { useState, useEffect } from 'react';
import { Modal, Stack, Button, Group, Tabs } from '@mantine/core';
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
}

export const PlanForm: React.FC<PlanFormProps> = ({
  opened,
  onClose,
  onSubmit,
  services,
  initialData,
  defaultServiceId,
}) => {
  const [formData, setFormData] = useState<PlanFormData>({
    serviceId: defaultServiceId || '',
    name: '',
    vehicleType: 'car',
    locationType: 'in_premise',
    duration: 60,
    basePrice: 0,
    tax: 18,
    warranty: '',
    guarantee: '',
    badge: '',
    fuelTypes: [],
    features: [],
    faqs: [],
    serviceOutcomes: [],
    additionalServices: [],
    steps: [],
  });

  const [loading, setLoading] = useState(false);

  useEffect(() => {
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
        fuelTypes: (initialData.fuelTypes?.filter((f): f is 'diesel' | 'petrol' => f === 'diesel' || f === 'petrol')) || [],
        features: initialData.features?.map(f => ({ 
          feature: f.feature, 
          displayOrder: f.display_order 
        })) || [],
        faqs: initialData.faqs?.map(f => ({ 
          question: f.question, 
          answer: f.answer, 
          displayOrder: f.display_order 
        })) || [],
        serviceOutcomes: initialData.serviceOutcomes?.map(o => ({ 
          title: o.title, 
          imageUrl: o.image_url, 
          description: o.description, 
          displayOrder: o.display_order 
        })) || [],
        additionalServices: initialData.additionalServices?.map(a => ({ 
          serviceName: a.service_name, 
          displayOrder: a.display_order 
        })) || [],
        steps: initialData.steps?.map(s => ({ 
          stepDescription: s.step_description, 
          displayOrder: s.display_order 
        })) || [],
      });
    } else if (defaultServiceId && !formData.serviceId) {
      setFormData(prev => ({ ...prev, serviceId: defaultServiceId }));
    }
  }, [initialData, defaultServiceId]);

  const handleFieldChange = (field: string, value: any) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  const handleSubmit = async () => {
    setLoading(true);
    try {
      // Upload outcome images if needed
      const updatedOutcomes = await Promise.all(
        formData.serviceOutcomes.map(async (outcome) => {
          if ((outcome as any).imageFile) {
            const imageUrl = await plansService.uploadOutcomeImage(
              (outcome as any).imageFile,
              initialData?.id || 'temp'
            );
            return { ...outcome, imageUrl };
          }
          return outcome;
        })
      );

      await onSubmit({
        ...formData,
        serviceOutcomes: updatedOutcomes,
      });
      
      onClose();
      resetForm();
    } finally {
      setLoading(false);
    }
  };

  const resetForm = () => {
    setFormData({
      serviceId: defaultServiceId || '',
      name: '',
      vehicleType: 'car',
      locationType: 'in_premise',
      duration: 60,
      basePrice: 0,
      tax: 18,
      warranty: '',
      guarantee: '',
      badge: '',
      fuelTypes: [],
      features: [],
      faqs: [],
      serviceOutcomes: [],
      additionalServices: [],
      steps: [],
    });
  };

  return (
    <Modal
      opened={opened}
      onClose={onClose}
      title={initialData ? 'Edit Plan' : 'Create Plan'}
      size="xl"
    >
      <Tabs defaultValue="basic">
        <Tabs.List>
          <Tabs.Tab value="basic">Basic Info</Tabs.Tab>
          <Tabs.Tab value="details">Details</Tabs.Tab>
          <Tabs.Tab value="faqs">FAQs</Tabs.Tab>
          <Tabs.Tab value="outcomes">Outcomes</Tabs.Tab>
        </Tabs.List>

        <Tabs.Panel value="basic" pt="md">
          <Stack>
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
          <Stack>
            <PlanFeaturesList
              features={formData.features}
              onChange={(features) => handleFieldChange('features', features)}
            />
            <PlanAdditionalServices
              services={formData.additionalServices}
              onChange={(services) => handleFieldChange('additionalServices', services)}
            />
            <PlanStepsList
              steps={formData.steps}
              onChange={(steps) => handleFieldChange('steps', steps)}
            />
          </Stack>
        </Tabs.Panel>

        <Tabs.Panel value="faqs" pt="md">
          <PlanFaqsList
            faqs={formData.faqs}
            onChange={(faqs) => handleFieldChange('faqs', faqs)}
          />
        </Tabs.Panel>

        <Tabs.Panel value="outcomes" pt="md">
          <PlanOutcomesList
            outcomes={formData.serviceOutcomes}
            onChange={(outcomes) => handleFieldChange('serviceOutcomes', outcomes)}
          />
        </Tabs.Panel>
      </Tabs>

      <Group justify="flex-end" mt="xl">
        <Button variant="subtle" onClick={onClose}>
          Cancel
        </Button>
        <Button onClick={handleSubmit} loading={loading}>
          {initialData ? 'Update' : 'Create'}
        </Button>
      </Group>
    </Modal>
  );
};


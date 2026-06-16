import { Stack, TextInput, Group, ActionIcon } from '@mantine/core';
import { IconTrash } from '@tabler/icons-react';
import { PlanListSection, planItemCardStyle } from './plan_list_section';

interface AdditionalService {
  serviceName: string;
  displayOrder: number;
}

interface PlanAdditionalServicesProps {
  services: AdditionalService[];
  onChange: (services: AdditionalService[]) => void;
  disabled?: boolean;
}

export const PlanAdditionalServices: React.FC<PlanAdditionalServicesProps> = ({ services, onChange, disabled }) => {
  const addService = () => {
    onChange([...services, { serviceName: '', displayOrder: services.length }]);
  };

  const removeService = (index: number) => {
    onChange(services.filter((_, i) => i !== index));
  };

  const updateService = (index: number, value: string) => {
    const updated = [...services];
    updated[index] = { ...updated[index], serviceName: value };
    onChange(updated);
  };

  return (
    <PlanListSection
      title="Additional Services"
      addLabel="Add Service"
      onAdd={addService}
      isEmpty={services.length === 0}
      emptyText="No additional services added yet."
    >
      <Stack gap="sm">
        {services.map((service, index) => (
          <div key={index} style={planItemCardStyle}>
            <Group gap="sm" wrap="nowrap">
              <TextInput
                placeholder="Service name"
                value={service.serviceName}
                onChange={(e) => updateService(index, e.target.value)}
                style={{ flex: 1 }}
                disabled={disabled}
              />
              <ActionIcon color="red" variant="subtle" onClick={() => removeService(index)} disabled={disabled}>
                <IconTrash size={16} />
              </ActionIcon>
            </Group>
          </div>
        ))}
      </Stack>
    </PlanListSection>
  );
};

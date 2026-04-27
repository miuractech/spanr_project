import { Stack, TextInput, Button, Group, ActionIcon, Text } from '@mantine/core';
import { IconPlus, IconTrash } from '@tabler/icons-react';

interface AdditionalService {
  serviceName: string;
  displayOrder: number;
}

interface PlanAdditionalServicesProps {
  services: AdditionalService[];
  onChange: (services: AdditionalService[]) => void;
}

export const PlanAdditionalServices: React.FC<PlanAdditionalServicesProps> = ({ services, onChange }) => {
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
    <Stack gap="xs">
      <Group justify="space-between">
        <Text size="sm" fw={500}>Additional Services</Text>
        <Button size="xs" leftSection={<IconPlus size={14} />} onClick={addService}>
          Add Service
        </Button>
      </Group>

      {services.map((service, index) => (
        <Group key={index} gap="xs">
          <TextInput
            placeholder="Service name"
            value={service.serviceName}
            onChange={(e) => updateService(index, e.target.value)}
            style={{ flex: 1 }}
          />
          <ActionIcon color="red" onClick={() => removeService(index)}>
            <IconTrash size={16} />
          </ActionIcon>
        </Group>
      ))}
    </Stack>
  );
};


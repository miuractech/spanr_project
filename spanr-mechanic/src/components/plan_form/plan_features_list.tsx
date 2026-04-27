import { Stack, TextInput, Button, Group, ActionIcon, Text } from '@mantine/core';
import { IconPlus, IconTrash } from '@tabler/icons-react';

interface Feature {
  feature: string;
  displayOrder: number;
}

interface PlanFeaturesListProps {
  features: Feature[];
  onChange: (features: Feature[]) => void;
}

export const PlanFeaturesList: React.FC<PlanFeaturesListProps> = ({ features, onChange }) => {
  const addFeature = () => {
    onChange([...features, { feature: '', displayOrder: features.length }]);
  };

  const removeFeature = (index: number) => {
    onChange(features.filter((_, i) => i !== index));
  };

  const updateFeature = (index: number, value: string) => {
    const updated = [...features];
    updated[index] = { ...updated[index], feature: value };
    onChange(updated);
  };

  return (
    <Stack gap="xs">
      <Group justify="space-between">
        <Text size="sm" fw={500}>Features</Text>
        <Button size="xs" leftSection={<IconPlus size={14} />} onClick={addFeature}>
          Add Feature
        </Button>
      </Group>

      {features.map((feature, index) => (
        <Group key={index} gap="xs">
          <TextInput
            placeholder="Feature description"
            value={feature.feature}
            onChange={(e) => updateFeature(index, e.target.value)}
            style={{ flex: 1 }}
          />
          <ActionIcon color="red" onClick={() => removeFeature(index)}>
            <IconTrash size={16} />
          </ActionIcon>
        </Group>
      ))}
    </Stack>
  );
};


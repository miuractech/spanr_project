import { Stack, TextInput, Group, ActionIcon } from '@mantine/core';
import { IconTrash } from '@tabler/icons-react';
import { PlanListSection, planItemCardStyle } from './plan_list_section';

interface Feature {
  feature: string;
  displayOrder: number;
}

interface PlanFeaturesListProps {
  features: Feature[];
  onChange: (features: Feature[]) => void;
  disabled?: boolean;
}

export const PlanFeaturesList: React.FC<PlanFeaturesListProps> = ({ features, onChange, disabled }) => {
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
    <PlanListSection
      title="Features"
      addLabel="Add Feature"
      onAdd={addFeature}
      isEmpty={features.length === 0}
      emptyText="No features added yet."
    >
      <Stack gap="sm">
        {features.map((feature, index) => (
          <div key={index} style={planItemCardStyle}>
            <Group gap="sm" wrap="nowrap">
              <TextInput
                placeholder="Feature description"
                value={feature.feature}
                onChange={(e) => updateFeature(index, e.target.value)}
                style={{ flex: 1 }}
                disabled={disabled}
              />
              <ActionIcon color="red" variant="subtle" onClick={() => removeFeature(index)} disabled={disabled}>
                <IconTrash size={16} />
              </ActionIcon>
            </Group>
          </div>
        ))}
      </Stack>
    </PlanListSection>
  );
};

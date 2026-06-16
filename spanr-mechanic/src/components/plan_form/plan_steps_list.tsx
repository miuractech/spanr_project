import { Stack, TextInput, Group, ActionIcon, Text } from '@mantine/core';
import { IconTrash } from '@tabler/icons-react';
import { PlanListSection, planItemCardStyle } from './plan_list_section';

interface Step {
  stepDescription: string;
  displayOrder: number;
}

interface PlanStepsListProps {
  steps: Step[];
  onChange: (steps: Step[]) => void;
  disabled?: boolean;
}

export const PlanStepsList: React.FC<PlanStepsListProps> = ({ steps, onChange, disabled }) => {
  const addStep = () => {
    onChange([...steps, { stepDescription: '', displayOrder: steps.length }]);
  };

  const removeStep = (index: number) => {
    onChange(steps.filter((_, i) => i !== index));
  };

  const updateStep = (index: number, value: string) => {
    const updated = [...steps];
    updated[index] = { ...updated[index], stepDescription: value };
    onChange(updated);
  };

  return (
    <PlanListSection
      title="Process Steps"
      addLabel="Add Step"
      onAdd={addStep}
      isEmpty={steps.length === 0}
      emptyText="No process steps added yet."
    >
      <Stack gap="sm">
        {steps.map((step, index) => (
          <div key={index} style={planItemCardStyle}>
            <Group gap="sm" wrap="nowrap">
              <Text size="sm" c="dimmed" fw={600} style={{ width: 24 }}>
                {index + 1}.
              </Text>
              <TextInput
                placeholder="Step description"
                value={step.stepDescription}
                onChange={(e) => updateStep(index, e.target.value)}
                style={{ flex: 1 }}
                disabled={disabled}
              />
              <ActionIcon color="red" variant="subtle" onClick={() => removeStep(index)} disabled={disabled}>
                <IconTrash size={16} />
              </ActionIcon>
            </Group>
          </div>
        ))}
      </Stack>
    </PlanListSection>
  );
};

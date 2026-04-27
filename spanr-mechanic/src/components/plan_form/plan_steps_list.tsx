import { Stack, TextInput, Button, Group, ActionIcon, Text } from '@mantine/core';
import { IconPlus, IconTrash } from '@tabler/icons-react';

interface Step {
  stepDescription: string;
  displayOrder: number;
}

interface PlanStepsListProps {
  steps: Step[];
  onChange: (steps: Step[]) => void;
}

export const PlanStepsList: React.FC<PlanStepsListProps> = ({ steps, onChange }) => {
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
    <Stack gap="xs">
      <Group justify="space-between">
        <Text size="sm" fw={500}>Process Steps</Text>
        <Button size="xs" leftSection={<IconPlus size={14} />} onClick={addStep}>
          Add Step
        </Button>
      </Group>

      {steps.map((step, index) => (
        <Group key={index} gap="xs">
          <Text size="sm" c="dimmed" style={{ width: '30px' }}>
            {index + 1}.
          </Text>
          <TextInput
            placeholder="Step description"
            value={step.stepDescription}
            onChange={(e) => updateStep(index, e.target.value)}
            style={{ flex: 1 }}
          />
          <ActionIcon color="red" onClick={() => removeStep(index)}>
            <IconTrash size={16} />
          </ActionIcon>
        </Group>
      ))}
    </Stack>
  );
};


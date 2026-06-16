import { Stack, TextInput, Group, ActionIcon, Textarea, FileInput, Image } from '@mantine/core';
import { IconTrash, IconUpload } from '@tabler/icons-react';
import { PlanListSection, planItemCardStyle } from './plan_list_section';

interface Outcome {
  title: string;
  imageUrl: string;
  description: string;
  displayOrder: number;
  imageFile?: File;
}

interface PlanOutcomesListProps {
  outcomes: Outcome[];
  onChange: (outcomes: Outcome[]) => void;
  disabled?: boolean;
}

export const PlanOutcomesList: React.FC<PlanOutcomesListProps> = ({ outcomes, onChange, disabled }) => {
  const addOutcome = () => {
    onChange([...outcomes, {
      title: '',
      imageUrl: '',
      description: '',
      displayOrder: outcomes.length,
    }]);
  };

  const removeOutcome = (index: number) => {
    onChange(outcomes.filter((_, i) => i !== index));
  };

  const updateOutcome = (index: number, field: keyof Outcome, value: string) => {
    const updated = [...outcomes];
    updated[index] = { ...updated[index], [field]: value };
    onChange(updated);
  };

  const handleImageChange = (index: number, file: File | null) => {
    if (file) {
      const updated = [...outcomes];
      updated[index] = {
        ...updated[index],
        imageFile: file,
        imageUrl: URL.createObjectURL(file),
      };
      onChange(updated);
    }
  };

  return (
    <PlanListSection
      title="Service Outcomes"
      addLabel="Add Outcome"
      onAdd={addOutcome}
      isEmpty={outcomes.length === 0}
      emptyText="No outcomes added yet."
    >
      <Stack gap="sm">
        {outcomes.map((outcome, index) => (
          <div key={index} style={planItemCardStyle}>
            <Group align="flex-start" wrap="nowrap">
              <Stack gap="sm" style={{ flex: 1 }}>
                <TextInput
                  label="Title"
                  placeholder="Outcome title"
                  value={outcome.title}
                  onChange={(e) => updateOutcome(index, 'title', e.target.value)}
                  disabled={disabled}
                />
                <Textarea
                  label="Description"
                  placeholder="Describe the outcome"
                  value={outcome.description}
                  onChange={(e) => updateOutcome(index, 'description', e.target.value)}
                  minRows={2}
                  autosize
                  disabled={disabled}
                />
                <FileInput
                  label="Image"
                  placeholder="Upload image"
                  accept="image/*"
                  leftSection={<IconUpload size={14} />}
                  onChange={(file) => handleImageChange(index, file)}
                  disabled={disabled}
                />
                {outcome.imageUrl && (
                  <Image src={outcome.imageUrl} alt={outcome.title} h={100} w={100} fit="cover" radius="sm" />
                )}
              </Stack>
              <ActionIcon
                color="red"
                variant="subtle"
                onClick={() => removeOutcome(index)}
                disabled={disabled}
                mt={24}
              >
                <IconTrash size={16} />
              </ActionIcon>
            </Group>
          </div>
        ))}
      </Stack>
    </PlanListSection>
  );
};

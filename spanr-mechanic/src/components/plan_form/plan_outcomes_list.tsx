import { Stack, TextInput, Button, Group, ActionIcon, Text, Textarea, FileInput, Image } from '@mantine/core';
import { IconPlus, IconTrash, IconUpload } from '@tabler/icons-react';
import { useState } from 'react';

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
}

export const PlanOutcomesList: React.FC<PlanOutcomesListProps> = ({ outcomes, onChange }) => {
  const addOutcome = () => {
    onChange([...outcomes, { 
      title: '', 
      imageUrl: '', 
      description: '', 
      displayOrder: outcomes.length 
    }]);
  };

  const removeOutcome = (index: number) => {
    onChange(outcomes.filter((_, i) => i !== index));
  };

  const updateOutcome = (index: number, field: keyof Outcome, value: any) => {
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
        imageUrl: URL.createObjectURL(file)
      };
      onChange(updated);
    }
  };

  return (
    <Stack gap="md">
      <Group justify="space-between">
        <Text size="sm" fw={500}>Service Outcomes</Text>
        <Button size="xs" leftSection={<IconPlus size={14} />} onClick={addOutcome}>
          Add Outcome
        </Button>
      </Group>

      {outcomes.map((outcome, index) => (
        <Stack key={index} gap="xs" p="sm" style={{ border: '1px solid #e9ecef', borderRadius: '4px' }}>
          <Group align="flex-start">
            <Stack gap="xs" style={{ flex: 1 }}>
              <TextInput
                placeholder="Title"
                value={outcome.title}
                onChange={(e) => updateOutcome(index, 'title', e.target.value)}
              />
              <Textarea
                placeholder="Description"
                value={outcome.description}
                onChange={(e) => updateOutcome(index, 'description', e.target.value)}
                minRows={2}
              />
              <FileInput
                placeholder="Upload image"
                accept="image/*"
                leftSection={<IconUpload size={14} />}
                onChange={(file) => handleImageChange(index, file)}
              />
              {outcome.imageUrl && (
                <Image src={outcome.imageUrl} alt={outcome.title} h={100} w={100} fit="cover" />
              )}
            </Stack>
            <ActionIcon color="red" onClick={() => removeOutcome(index)}>
              <IconTrash size={16} />
            </ActionIcon>
          </Group>
        </Stack>
      ))}
    </Stack>
  );
};


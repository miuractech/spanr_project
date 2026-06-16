import { useState } from 'react';
import { Group, TextInput, Button, Badge, Stack, Text } from '@mantine/core';
import { IconPlus, IconX } from '@tabler/icons-react';

interface StaffSkillsInputProps {
  skills: string[];
  onChange: (skills: string[]) => void;
}

export const StaffSkillsInput: React.FC<StaffSkillsInputProps> = ({ skills, onChange }) => {
  const [newSkill, setNewSkill] = useState('');

  const addSkill = () => {
    const trimmed = newSkill.trim();
    if (!trimmed || skills.includes(trimmed)) return;
    onChange([...skills, trimmed]);
    setNewSkill('');
  };

  return (
    <Stack gap="xs">
      <Text size="sm" fw={500}>Skills</Text>
      <Group gap="xs">
        <TextInput
          placeholder="e.g. Brake Repair"
          value={newSkill}
          onChange={(e) => setNewSkill(e.target.value)}
          onKeyDown={(e) => e.key === 'Enter' && (e.preventDefault(), addSkill())}
          style={{ flex: 1 }}
        />
        <Button leftSection={<IconPlus size={14} />} onClick={addSkill} color="orange" variant="light">
          Add
        </Button>
      </Group>
      <Group gap="xs">
        {skills.map((skill) => (
          <Badge
            key={skill}
            rightSection={
              <IconX
                size={12}
                style={{ cursor: 'pointer' }}
                onClick={() => onChange(skills.filter((s) => s !== skill))}
              />
            }
            color="orange"
            variant="light"
          >
            {skill}
          </Badge>
        ))}
      </Group>
    </Stack>
  );
};

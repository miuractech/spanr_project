import { useState } from 'react';
import { Group, TextInput, Button, Badge, Stack } from '@mantine/core';
import { IconPlus, IconX } from '@tabler/icons-react';
import { staffAddButtonProps } from './staff_form_section';

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
    <Stack gap="sm">
      <Group align="flex-end" gap="sm" wrap="nowrap">
        <TextInput
          label="Skill"
          placeholder="e.g. Brake Repair"
          value={newSkill}
          onChange={(e) => setNewSkill(e.target.value)}
          onKeyDown={(e) => e.key === 'Enter' && (e.preventDefault(), addSkill())}
          style={{ flex: 1 }}
        />
        <Button
          {...staffAddButtonProps}
          leftSection={<IconPlus size={16} />}
          onClick={addSkill}
          disabled={!newSkill.trim()}
        >
          Add
        </Button>
      </Group>
      {skills.length > 0 && (
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
              size="lg"
              radius="md"
            >
              {skill}
            </Badge>
          ))}
        </Group>
      )}
    </Stack>
  );
};

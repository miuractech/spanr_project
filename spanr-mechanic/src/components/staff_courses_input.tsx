import { useState } from 'react';
import {
  Group,
  TextInput,
  Button,
  Stack,
  Text,
  ActionIcon,
  Paper,
  ThemeIcon,
} from '@mantine/core';
import { IconPlus, IconX, IconSchool } from '@tabler/icons-react';
import type { StaffCourseInput } from '../staff/staff.service';
import { staffAddButtonProps } from './staff_form_section';

interface StaffCoursesInputProps {
  courses: StaffCourseInput[];
  onChange: (courses: StaffCourseInput[]) => void;
}

export const StaffCoursesInput: React.FC<StaffCoursesInputProps> = ({ courses, onChange }) => {
  const [courseName, setCourseName] = useState('');
  const [institution, setInstitution] = useState('');
  const [completedDate, setCompletedDate] = useState('');

  const addCourse = () => {
    if (!courseName.trim()) return;
    onChange([
      ...courses,
      {
        courseName: courseName.trim(),
        institution: institution.trim() || undefined,
        completedDate: completedDate || undefined,
      },
    ]);
    setCourseName('');
    setInstitution('');
    setCompletedDate('');
  };

  return (
    <Stack gap="sm">
      <TextInput
        label="Course name"
        placeholder="Advanced Engine Diagnostics"
        value={courseName}
        onChange={(e) => setCourseName(e.target.value)}
      />
      <Group align="flex-end" gap="sm" wrap="nowrap">
        <TextInput
          label="Institution (optional)"
          placeholder="ITI Mumbai"
          value={institution}
          onChange={(e) => setInstitution(e.target.value)}
          style={{ flex: 1 }}
        />
        <TextInput
          type="date"
          label="Completed (optional)"
          value={completedDate}
          onChange={(e) => setCompletedDate(e.target.value)}
          w={170}
        />
        <Button
          {...staffAddButtonProps}
          leftSection={<IconPlus size={16} />}
          onClick={addCourse}
          disabled={!courseName.trim()}
        >
          Add
        </Button>
      </Group>
      {courses.length > 0 && (
        <Stack gap="xs">
          {courses.map((course, index) => (
            <Paper key={`${course.courseName}-${index}`} withBorder p="sm" radius="md" bg="white">
              <Group justify="space-between" wrap="nowrap">
                <Group gap="sm" wrap="nowrap">
                  <ThemeIcon color="orange" variant="light" size="lg" radius="md">
                    <IconSchool size={18} />
                  </ThemeIcon>
                  <div>
                    <Text size="sm" fw={600}>{course.courseName}</Text>
                    <Text size="xs" c="dimmed">
                      {[course.institution, course.completedDate].filter(Boolean).join(' · ')}
                    </Text>
                  </div>
                </Group>
                <ActionIcon color="red" variant="subtle" onClick={() => onChange(courses.filter((_, i) => i !== index))}>
                  <IconX size={16} />
                </ActionIcon>
              </Group>
            </Paper>
          ))}
        </Stack>
      )}
    </Stack>
  );
};

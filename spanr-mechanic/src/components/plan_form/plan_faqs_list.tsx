import { Stack, TextInput, Button, Group, ActionIcon, Text, Textarea } from '@mantine/core';
import { IconPlus, IconTrash } from '@tabler/icons-react';

interface Faq {
  question: string;
  answer: string;
  displayOrder: number;
}

interface PlanFaqsListProps {
  faqs: Faq[];
  onChange: (faqs: Faq[]) => void;
}

export const PlanFaqsList: React.FC<PlanFaqsListProps> = ({ faqs, onChange }) => {
  const addFaq = () => {
    onChange([...faqs, { question: '', answer: '', displayOrder: faqs.length }]);
  };

  const removeFaq = (index: number) => {
    onChange(faqs.filter((_, i) => i !== index));
  };

  const updateFaq = (index: number, field: 'question' | 'answer', value: string) => {
    const updated = [...faqs];
    updated[index] = { ...updated[index], [field]: value };
    onChange(updated);
  };

  return (
    <Stack gap="md">
      <Group justify="space-between">
        <Text size="sm" fw={500}>FAQs</Text>
        <Button size="xs" leftSection={<IconPlus size={14} />} onClick={addFaq}>
          Add FAQ
        </Button>
      </Group>

      {faqs.map((faq, index) => (
        <Stack key={index} gap="xs" p="sm" style={{ border: '1px solid #e9ecef', borderRadius: '4px' }}>
          <Group align="flex-start">
            <Stack gap="xs" style={{ flex: 1 }}>
              <TextInput
                placeholder="Question"
                value={faq.question}
                onChange={(e) => updateFaq(index, 'question', e.target.value)}
              />
              <Textarea
                placeholder="Answer"
                value={faq.answer}
                onChange={(e) => updateFaq(index, 'answer', e.target.value)}
                minRows={2}
              />
            </Stack>
            <ActionIcon color="red" onClick={() => removeFaq(index)}>
              <IconTrash size={16} />
            </ActionIcon>
          </Group>
        </Stack>
      ))}
    </Stack>
  );
};


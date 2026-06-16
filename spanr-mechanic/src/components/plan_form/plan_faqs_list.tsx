import { Stack, TextInput, Group, ActionIcon, Textarea } from '@mantine/core';
import { IconTrash } from '@tabler/icons-react';
import { PlanListSection, planItemCardStyle } from './plan_list_section';

interface Faq {
  question: string;
  answer: string;
  displayOrder: number;
}

interface PlanFaqsListProps {
  faqs: Faq[];
  onChange: (faqs: Faq[]) => void;
  disabled?: boolean;
}

export const PlanFaqsList: React.FC<PlanFaqsListProps> = ({ faqs, onChange, disabled }) => {
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
    <PlanListSection
      title="FAQs"
      addLabel="Add FAQ"
      onAdd={addFaq}
      isEmpty={faqs.length === 0}
      emptyText="No FAQs added yet."
    >
      <Stack gap="sm">
        {faqs.map((faq, index) => (
          <div key={index} style={planItemCardStyle}>
            <Group align="flex-start" wrap="nowrap">
              <Stack gap="sm" style={{ flex: 1 }}>
                <TextInput
                  label="Question"
                  placeholder="e.g. How long does the service take?"
                  value={faq.question}
                  onChange={(e) => updateFaq(index, 'question', e.target.value)}
                  disabled={disabled}
                />
                <Textarea
                  label="Answer"
                  placeholder="Enter the answer"
                  value={faq.answer}
                  onChange={(e) => updateFaq(index, 'answer', e.target.value)}
                  minRows={2}
                  autosize
                  disabled={disabled}
                />
              </Stack>
              <ActionIcon
                color="red"
                variant="subtle"
                onClick={() => removeFaq(index)}
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

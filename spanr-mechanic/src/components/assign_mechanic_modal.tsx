import { useState } from 'react';
import { Modal, Stack, Text, Group, Badge, Button, Textarea, Radio, Loader } from '@mantine/core';
import { IconUser, IconBriefcase } from '@tabler/icons-react';
import { useStaffWorkload } from '../assignments/assignments.hook';
import { assignmentsService } from '../assignments/assignments.service';
import type { StaffWorkload } from '../assignments/assignments.types';

interface AssignMechanicModalProps {
  opened: boolean;
  onClose: () => void;
  orderId: string;
  companyId: string;
  currentStaffId?: string;
  onAssigned: () => void;
}

const availabilityColor = (a: string) => {
  if (a === 'available') return 'green';
  if (a === 'busy') return 'orange';
  return 'gray';
};

export const AssignMechanicModal: React.FC<AssignMechanicModalProps> = ({
  opened,
  onClose,
  orderId,
  companyId,
  currentStaffId,
  onAssigned,
}) => {
  const { workload, loading } = useStaffWorkload(companyId);
  const [selectedId, setSelectedId] = useState<string | null>(currentStaffId ?? null);
  const [notes, setNotes] = useState('');
  const [submitting, setSubmitting] = useState(false);

  const handleAssign = async () => {
    if (!selectedId) return;
    setSubmitting(true);
    try {
      await assignmentsService.assignOrder(orderId, selectedId, notes || undefined);
      onAssigned();
      onClose();
    } finally {
      setSubmitting(false);
    }
  };

  const renderStaff = (member: StaffWorkload) => (
    <Radio.Card
      key={member.staff_id}
      value={member.staff_id}
      radius="md"
      p="sm"
      style={{ border: selectedId === member.staff_id ? '2px solid #FC8019' : undefined }}
    >
      <Group justify="space-between" wrap="nowrap">
        <Group gap="sm">
          <IconUser size={18} />
          <div>
            <Text fw={500} size="sm">{member.name}</Text>
            <Text size="xs" c="dimmed">{member.email}</Text>
          </div>
        </Group>
        <Group gap="xs">
          <Badge color={availabilityColor(member.availability)} size="sm" variant="light">
            {member.availability}
          </Badge>
          <Badge color="blue" size="sm" variant="outline" leftSection={<IconBriefcase size={12} />}>
            {member.active_jobs} jobs
          </Badge>
        </Group>
      </Group>
      {member.skills && member.skills.length > 0 && (
        <Group gap={4} mt="xs">
          {member.skills.slice(0, 4).map((s) => (
            <Badge key={s} size="xs" color="orange" variant="light">{s}</Badge>
          ))}
        </Group>
      )}
    </Radio.Card>
  );

  return (
    <Modal
      opened={opened}
      onClose={onClose}
      title={currentStaffId ? 'Reassign Mechanic' : 'Assign Mechanic'}
      size="lg"
    >
      {loading ? (
        <Loader />
      ) : (
        <Stack gap="md">
          <Radio.Group value={selectedId} onChange={setSelectedId}>
            <Stack gap="sm">
              {workload.map(renderStaff)}
            </Stack>
          </Radio.Group>
          <Textarea
            label="Notes (optional)"
            placeholder="Assignment notes..."
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            minRows={2}
          />
          <Group justify="flex-end">
            <Button variant="subtle" onClick={onClose}>Cancel</Button>
            <Button color="orange" onClick={handleAssign} loading={submitting} disabled={!selectedId}>
              {currentStaffId ? 'Reassign' : 'Assign'}
            </Button>
          </Group>
        </Stack>
      )}
    </Modal>
  );
};

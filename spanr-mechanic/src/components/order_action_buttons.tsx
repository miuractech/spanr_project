import { Button, Group, Modal, Textarea, Stack, Alert } from '@mantine/core';
import { useState } from 'react';
import { IconCheck, IconX, IconPlayerPlay, IconPackage, IconCircleCheck, IconAlertTriangle } from '@tabler/icons-react';
import type { OrderStatus } from '../orders/orders.types';

interface OrderActionButtonsProps {
  currentStatus: OrderStatus;
  onUpdate: (status: OrderStatus, notes?: string) => Promise<void>;
}

interface StatusAction {
  label: string;
  icon: React.ReactNode;
  targetStatus: OrderStatus;
  color: string;
  confirmRequired?: boolean;
}

export const OrderActionButtons: React.FC<OrderActionButtonsProps> = ({
  currentStatus,
  onUpdate,
}) => {
  const [loading, setLoading] = useState(false);
  const [modalOpen, setModalOpen] = useState(false);
  const [selectedAction, setSelectedAction] = useState<StatusAction | null>(null);
  const [notes, setNotes] = useState('');

  const getAvailableActions = (): StatusAction[] => {
    switch (currentStatus) {
      case 'created':
        return [
          { label: 'Accept Order', icon: <IconCheck size={16} />, targetStatus: 'accepted', color: 'green' },
          { label: 'Decline Order', icon: <IconX size={16} />, targetStatus: 'cancelled', color: 'red', confirmRequired: true },
        ];
      case 'accepted':
        return [
          { label: 'Start Work', icon: <IconPlayerPlay size={16} />, targetStatus: 'in_progress', color: 'blue' },
          { label: 'Cancel Order', icon: <IconX size={16} />, targetStatus: 'cancelled', color: 'red', confirmRequired: true },
        ];
      case 'in_progress':
        return [
          { label: 'Mark Ready for Delivery', icon: <IconPackage size={16} />, targetStatus: 'ready_for_delivery', color: 'grape' },
          { label: 'Report Issue', icon: <IconAlertTriangle size={16} />, targetStatus: 'dispute', color: 'orange', confirmRequired: true },
        ];
      case 'ready_for_delivery':
        return [
          { label: 'Complete Order', icon: <IconCircleCheck size={16} />, targetStatus: 'completed', color: 'green' },
        ];
      case 'dispute':
        return [
          { label: 'Resume Work', icon: <IconPlayerPlay size={16} />, targetStatus: 'in_progress', color: 'blue' },
          { label: 'Cancel Order', icon: <IconX size={16} />, targetStatus: 'cancelled', color: 'red', confirmRequired: true },
        ];
      case 'completed':
      case 'cancelled':
        return [];
      default:
        return [];
    }
  };

  const handleActionClick = (action: StatusAction) => {
    setSelectedAction(action);
    if (action.confirmRequired) {
      setModalOpen(true);
    } else {
      handleConfirm(action);
    }
  };

  const handleConfirm = async (action: StatusAction, confirmNotes?: string) => {
    setLoading(true);
    try {
      await onUpdate(action.targetStatus, confirmNotes || notes);
      setNotes('');
      setModalOpen(false);
      setSelectedAction(null);
    } finally {
      setLoading(false);
    }
  };

  const actions = getAvailableActions();

  if (actions.length === 0) {
    return (
      <Alert color="gray" variant="light">
        No actions available for this order status.
      </Alert>
    );
  }

  return (
    <>
      <Group gap="md">
        {actions.map((action) => (
          <Button
            key={action.targetStatus}
            leftSection={action.icon}
            color={action.color}
            onClick={() => handleActionClick(action)}
            loading={loading && selectedAction?.targetStatus === action.targetStatus}
          >
            {action.label}
          </Button>
        ))}
      </Group>

      <Modal
        opened={modalOpen}
        onClose={() => setModalOpen(false)}
        title={`${selectedAction?.label}`}
        size="md"
      >
        <Stack gap="md">
          <Alert color={selectedAction?.color || 'blue'}>
            Are you sure you want to {selectedAction?.label.toLowerCase()}?
          </Alert>
          <Textarea
            label="Notes (optional)"
            placeholder="Add any notes about this action..."
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            minRows={3}
          />
          <Group justify="flex-end">
            <Button variant="subtle" onClick={() => setModalOpen(false)}>
              Cancel
            </Button>
            <Button
              color={selectedAction?.color}
              onClick={() => selectedAction && handleConfirm(selectedAction, notes)}
              loading={loading}
            >
              Confirm
            </Button>
          </Group>
        </Stack>
      </Modal>
    </>
  );
};


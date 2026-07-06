import { useEffect, useState } from 'react';
import {
  Stack,
  Text,
  Badge,
  Paper,
  Group,
  Button,
  Alert,
  Loader,
  Image,
  NumberFormatter,
  Divider,
  ActionIcon,
  Tooltip,
} from '@mantine/core';
import {
  IconAlertCircle,
  IconCheck,
  IconX,
  IconClock,
} from '@tabler/icons-react';
import { extraWorkService } from '../extra-work/extra_work.service';
import type { ExtraWorkRequest } from '../extra-work/extra_work.types';
import { useNotification } from '../core/notification.hook';

const STATUS_COLOR: Record<string, string> = {
  pending: 'yellow',
  approved: 'green',
  rejected: 'red',
};

interface ExtraWorkTabProps {
  orderId: string;
  orderStatus: string;
}

export const ExtraWorkTab: React.FC<ExtraWorkTabProps> = ({ orderId, orderStatus }) => {
  const [requests, setRequests] = useState<ExtraWorkRequest[]>([]);
  const [loading, setLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState<string | null>(null);
  const notification = useNotification();

  const load = async () => {
    try {
      setLoading(true);
      setRequests(await extraWorkService.getByOrderId(orderId));
    } catch (err) {
      notification.showError(err instanceof Error ? err.message : 'Failed to load requests');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, [orderId]);

  const handleApprove = async (id: string) => {
    setActionLoading(id);
    try {
      await extraWorkService.approve(id, orderId);
      notification.showSuccess('Extra work approved');
      await load();
    } catch (err) {
      notification.showError(err instanceof Error ? err.message : 'Failed to approve');
    } finally {
      setActionLoading(null);
    }
  };

  const handleReject = async (id: string) => {
    const reason = window.prompt('Rejection reason (optional):') ?? undefined;
    setActionLoading(id);
    try {
      await extraWorkService.reject(id, reason);
      notification.showSuccess('Extra work rejected');
      await load();
    } catch (err) {
      notification.showError(err instanceof Error ? err.message : 'Failed to reject');
    } finally {
      setActionLoading(null);
    }
  };

  if (loading) return <Loader size="sm" color="orange" />;

  if (requests.length === 0) {
    return (
      <Alert icon={<IconAlertCircle size={16} />} color="gray" variant="light">
        No extra work requests for this order yet.
        {orderStatus === 'in_progress' &&
          ' The mechanic can submit a request from their app when additional work is needed.'}
      </Alert>
    );
  }

  return (
    <Stack gap="md">
      {orderStatus === 'on_hold' && (
        <Alert icon={<IconClock size={16} />} color="yellow">
          This order is on hold — waiting for customer approval of extra work.
        </Alert>
      )}

      {requests.map((req) => (
        <Paper key={req.id} withBorder p="md" radius="md">
          <Group justify="space-between" mb="xs" wrap="wrap">
            <Group gap="xs">
              {req.mechanicName && (
                <Text size="sm" c="dimmed">
                  by {req.mechanicName}
                </Text>
              )}
              <Badge color={STATUS_COLOR[req.status] ?? 'gray'} size="sm">
                {req.status.toUpperCase()}
              </Badge>
            </Group>
            <Text size="xs" c="dimmed">
              {new Date(req.createdAt).toLocaleString()}
            </Text>
          </Group>

          <Text size="sm" mb="xs">
            {req.description}
          </Text>

          <Text size="sm" fw={700} mb="xs">
            Estimated cost:{' '}
            <NumberFormatter value={req.estimatedCost} prefix="₹" thousandSeparator />
          </Text>

          {req.photoUrl && (
            <Image
              src={req.photoUrl}
              alt="Extra work photo"
              h={160}
              w="auto"
              fit="contain"
              radius="sm"
              mb="xs"
              style={{ border: '1px solid #E0E0E0' }}
            />
          )}

          {req.rejectionReason && (
            <Text size="xs" c="red" mb="xs">
              Reason: {req.rejectionReason}
            </Text>
          )}

          {req.customerResponseAt && (
            <Text size="xs" c="dimmed">
              Customer responded: {new Date(req.customerResponseAt).toLocaleString()}
            </Text>
          )}

          {req.status === 'pending' && (
            <>
              <Divider my="xs" />
              <Group gap="xs">
                <Tooltip label="Approve on behalf of customer">
                  <Button
                    size="xs"
                    color="green"
                    leftSection={<IconCheck size={14} />}
                    loading={actionLoading === req.id}
                    onClick={() => handleApprove(req.id)}
                  >
                    Approve
                  </Button>
                </Tooltip>
                <Tooltip label="Reject on behalf of customer">
                  <ActionIcon
                    size="md"
                    color="red"
                    variant="light"
                    loading={actionLoading === req.id}
                    onClick={() => handleReject(req.id)}
                    aria-label="Reject"
                  >
                    <IconX size={14} />
                  </ActionIcon>
                </Tooltip>
              </Group>
            </>
          )}
        </Paper>
      ))}
    </Stack>
  );
};

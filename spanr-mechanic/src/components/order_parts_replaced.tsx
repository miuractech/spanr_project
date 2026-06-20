import { useState, useEffect } from 'react';
import {
  Stack,
  Title,
  Paper,
  Text,
  Group,
  Badge,
  Loader,
  Modal,
  SimpleGrid,
  Image,
  Divider,
} from '@mantine/core';
import { ordersService } from '../orders/orders.service';
import type { PartReplacement } from '../orders/orders.types';

interface OrderPartsReplacedProps {
  orderId: string;
}

export const OrderPartsReplaced: React.FC<OrderPartsReplacedProps> = ({ orderId }) => {
  const [parts, setParts] = useState<PartReplacement[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedPart, setSelectedPart] = useState<PartReplacement | null>(null);
  const [detailLoading, setDetailLoading] = useState(false);

  useEffect(() => {
    loadParts();
  }, [orderId]);

  const loadParts = async () => {
    try {
      setLoading(true);
      const data = await ordersService.getPartsReplaced(orderId);
      setParts(data);
    } catch (err) {
      console.error('Failed to load parts:', err);
    } finally {
      setLoading(false);
    }
  };

  const openPartDetail = async (partId: string) => {
    try {
      setDetailLoading(true);
      const data = await ordersService.getPartReplacementById(partId);
      setSelectedPart(data);
    } catch (err) {
      console.error('Failed to load part details:', err);
    } finally {
      setDetailLoading(false);
    }
  };

  if (loading) return <Loader />;

  return (
    <>
      <Paper withBorder p="md">
        <Stack gap="md">
          <Title order={4}>Parts Replacement</Title>

          {parts.length === 0 ? (
            <Text size="sm" c="dimmed">No parts replaced yet for this order.</Text>
          ) : (
            <Stack gap="xs">
              {parts.map((part) => (
                <Paper
                  key={part.id}
                  withBorder
                  p="sm"
                  radius="md"
                  style={{ cursor: 'pointer' }}
                  onClick={() => openPartDetail(part.id)}
                >
                  <Group justify="space-between" wrap="nowrap">
                    <div>
                      <Text fw={600} size="sm">{part.part_name}</Text>
                      <Text size="xs" c="dimmed">
                        {[part.part_number && `No. ${part.part_number}`, `Qty: ${part.quantity}`, part.brand]
                          .filter(Boolean)
                          .join(' · ')}
                      </Text>
                    </div>
                    <Group gap="xs" wrap="nowrap">
                      {part.cost != null && (
                        <Badge color="orange" variant="light">₹{part.cost}</Badge>
                      )}
                    </Group>
                  </Group>
                </Paper>
              ))}
            </Stack>
          )}
        </Stack>
      </Paper>

      <Modal
        opened={selectedPart !== null}
        onClose={() => setSelectedPart(null)}
        title={selectedPart?.part_name ?? 'Part Details'}
        size="lg"
      >
        {detailLoading ? (
          <Loader />
        ) : selectedPart ? (
          <Stack gap="sm">
            <SimpleGrid cols={{ base: 1, sm: 2 }}>
              {selectedPart.part_number && (
                <Text size="sm"><strong>Part Number:</strong> {selectedPart.part_number}</Text>
              )}
              {selectedPart.brand && (
                <Text size="sm"><strong>Brand:</strong> {selectedPart.brand}</Text>
              )}
              <Text size="sm"><strong>Quantity:</strong> {selectedPart.quantity}</Text>
              {selectedPart.cost != null && (
                <Text size="sm"><strong>Cost:</strong> ₹{selectedPart.cost}</Text>
              )}
              {selectedPart.km_reading != null && (
                <Text size="sm"><strong>KM Reading:</strong> {selectedPart.km_reading} km</Text>
              )}
            </SimpleGrid>

            {(selectedPart.before_photo_url || selectedPart.photo_url) && (
              <>
                <Divider my="xs" />
                {selectedPart.before_photo_url && (
                  <div>
                    <Text size="xs" fw={500} mb={4}>Before (Old Part)</Text>
                    <Image src={selectedPart.before_photo_url} radius="md" fit="contain" mah={240} />
                  </div>
                )}
                {selectedPart.photo_url && (
                  <div>
                    <Text size="xs" fw={500} mb={4}>After (New Part)</Text>
                    <Image src={selectedPart.photo_url} radius="md" fit="contain" mah={240} />
                  </div>
                )}
              </>
            )}
          </Stack>
        ) : null}
      </Modal>
    </>
  );
};

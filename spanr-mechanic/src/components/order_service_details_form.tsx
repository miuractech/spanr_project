import { useState, useEffect } from 'react';
import {
  Stack,
  Title,
  Textarea,
  NumberInput,
  Button,
  Paper,
  Loader,
} from '@mantine/core';
import { ordersService } from '../orders/orders.service';
import type { OrderServiceDetail } from '../orders/orders.types';

interface OrderServiceDetailsFormProps {
  orderId: string;
}

export const OrderServiceDetailsForm: React.FC<OrderServiceDetailsFormProps> = ({ orderId }) => {
  const [details, setDetails] = useState<Partial<OrderServiceDetail>>({
    description: '',
    parts_used: '',
    labor_hours: 0,
    additional_charges: 0,
    notes: '',
  });
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    loadDetails();
  }, [orderId]);

  const loadDetails = async () => {
    try {
      setLoading(true);
      const data = await ordersService.getOrderServiceDetails(orderId);
      if (data) {
        setDetails({
          description: data.description,
          parts_used: data.parts_used || '',
          labor_hours: data.labor_hours || 0,
          additional_charges: data.additional_charges || 0,
          notes: data.notes || '',
        });
      }
    } catch (err) {
      console.error('Failed to load service details:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async () => {
    try {
      setSaving(true);
      await ordersService.upsertOrderServiceDetails(orderId, details);
      await loadDetails();
    } catch (err) {
      console.error('Failed to save service details:', err);
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return <Loader />;
  }

  return (
    <Paper withBorder p="md">
      <Stack gap="md">
        <Title order={4}>Service Details</Title>

        <Textarea
          label="Service Description"
          placeholder="Describe the work performed..."
          value={details.description}
          onChange={(e) => setDetails({ ...details, description: e.target.value })}
          required
          minRows={3}
        />

        <Textarea
          label="Parts Used"
          placeholder="List all parts used..."
          value={details.parts_used}
          onChange={(e) => setDetails({ ...details, parts_used: e.target.value })}
          minRows={2}
        />

        <NumberInput
          label="Labor Hours"
          placeholder="0"
          value={details.labor_hours}
          onChange={(val) => setDetails({ ...details, labor_hours: Number(val) || 0 })}
          min={0}
          step={0.5}
          decimalScale={2}
        />

        <NumberInput
          label="Additional Charges (₹)"
          placeholder="0"
          value={details.additional_charges}
          onChange={(val) => setDetails({ ...details, additional_charges: Number(val) || 0 })}
          min={0}
          decimalScale={2}
          prefix="₹"
        />

        <Textarea
          label="Notes"
          placeholder="Any additional notes..."
          value={details.notes}
          onChange={(e) => setDetails({ ...details, notes: e.target.value })}
          minRows={2}
        />

        <Button
          onClick={handleSave}
          loading={saving}
          disabled={!details.description}
        >
          Save Service Details
        </Button>
      </Stack>
    </Paper>
  );
};


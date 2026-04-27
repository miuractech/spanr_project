import { useState } from 'react';
import {
  TextInput,
  Stack,
  SimpleGrid,
  Button,
  Group,
  NumberInput,
  Alert,
} from '@mantine/core';
import type { UseFormReturnType } from '@mantine/form';
import { IconCurrentLocation, IconAlertCircle } from '@tabler/icons-react';

interface LocationFormData {
  addressLine1: string;
  addressLine2: string;
  landmark: string;
  city: string;
  state: string;
  pincode: string;
  latitude: number | null;
  longitude: number | null;
}

interface CompanyLocationFormProps {
  form: UseFormReturnType<LocationFormData>;
}

export const CompanyLocationForm: React.FC<CompanyLocationFormProps> = ({
  form,
}) => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const getCurrentLocation = () => {
    if (!navigator.geolocation) {
      setError('Geolocation is not supported by your browser');
      return;
    }

    setLoading(true);
    setError('');

    navigator.geolocation.getCurrentPosition(
      (position) => {
        form.setFieldValue('latitude', position.coords.latitude);
        form.setFieldValue('longitude', position.coords.longitude);
        setLoading(false);
      },
      (error) => {
        setError(error.message);
        setLoading(false);
      },
      {
        enableHighAccuracy: true,
        timeout: 5000,
        maximumAge: 0,
      }
    );
  };

  return (
    <Stack gap="md">
      <TextInput
        label="Address Line 1"
        placeholder="123 Main Street"
        required
        {...form.getInputProps('addressLine1')}
      />

      <TextInput
        label="Address Line 2"
        placeholder="Near XYZ Mall"
        {...form.getInputProps('addressLine2')}
      />

      <TextInput
        label="Landmark"
        placeholder="Opposite ABC Bank"
        {...form.getInputProps('landmark')}
      />

      <SimpleGrid cols={3}>
        <TextInput
          label="City"
          placeholder="Mumbai"
          required
          {...form.getInputProps('city')}
        />

        <TextInput
          label="State"
          placeholder="Maharashtra"
          required
          {...form.getInputProps('state')}
        />

        <TextInput
          label="Pincode"
          placeholder="400001"
          required
          {...form.getInputProps('pincode')}
        />
      </SimpleGrid>

      <Group align="flex-end">
        <NumberInput
          label="Latitude"
          placeholder="19.0760"
          decimalScale={6}
          {...form.getInputProps('latitude')}
          style={{ flex: 1 }}
        />

        <NumberInput
          label="Longitude"
          placeholder="72.8777"
          decimalScale={6}
          {...form.getInputProps('longitude')}
          style={{ flex: 1 }}
        />

        <Button
          leftSection={<IconCurrentLocation size={16} />}
          onClick={getCurrentLocation}
          loading={loading}
        >
          Get Current Location
        </Button>
      </Group>

      {error && (
        <Alert icon={<IconAlertCircle size={16} />} color="red">
          {error}
        </Alert>
      )}
    </Stack>
  );
};


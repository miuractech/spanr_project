import { TextInput, Select, NumberInput, SimpleGrid } from '@mantine/core';

interface PlanBasicInfoProps {
  formData: any;
  services: Array<{ id: string; name: string }>;
  onChange: (field: string, value: any) => void;
}

export const PlanBasicInfo: React.FC<PlanBasicInfoProps> = ({ formData, services, onChange }) => {
  return (
    <>
      <Select
        label="Service"
        placeholder="Select service"
        required
        data={services.map(s => ({ value: s.id, label: s.name }))}
        value={formData.serviceId}
        onChange={(value) => onChange('serviceId', value)}
      />

      <TextInput
        label="Plan Name"
        placeholder="Basic Oil Change"
        required
        value={formData.name}
        onChange={(e) => onChange('name', e.target.value)}
      />

      <SimpleGrid cols={2}>
        <Select
          label="Vehicle Type"
          required
          data={[
            { value: 'car', label: 'Car' },
            { value: 'bike', label: 'Bike' },
          ]}
          value={formData.vehicleType}
          onChange={(value) => onChange('vehicleType', value)}
        />

        <Select
          label="Location Type"
          required
          data={[
            { value: 'in_premise', label: 'In Premise' },
            { value: 'shed', label: 'Shed' },
          ]}
          value={formData.locationType}
          onChange={(value) => onChange('locationType', value)}
        />
      </SimpleGrid>

      <SimpleGrid cols={3}>
        <NumberInput
          label="Duration (minutes)"
          placeholder="60"
          required
          min={0}
          value={formData.duration}
          onChange={(value) => onChange('duration', value)}
        />

        <NumberInput
          label="Base Price"
          placeholder="1000"
          required
          min={0}
          prefix="₹"
          decimalScale={2}
          value={formData.basePrice}
          onChange={(value) => onChange('basePrice', value)}
        />

        <NumberInput
          label="Tax (%)"
          placeholder="18"
          required
          min={0}
          max={100}
          decimalScale={2}
          value={formData.tax}
          onChange={(value) => onChange('tax', value)}
        />
      </SimpleGrid>

      <TextInput
        label="Warranty"
        placeholder="6 months"
        value={formData.warranty}
        onChange={(e) => onChange('warranty', e.target.value)}
      />

      <TextInput
        label="Guarantee"
        placeholder="100% satisfaction guaranteed"
        value={formData.guarantee}
        onChange={(e) => onChange('guarantee', e.target.value)}
      />

      <TextInput
        label="Badge"
        placeholder="Best Seller"
        value={formData.badge}
        onChange={(e) => onChange('badge', e.target.value)}
      />

      <SimpleGrid cols={2}>
        <Select
          label="Plan Type"
          required
          data={[
            { value: 'package', label: 'Package (Fixed tier)' },
            { value: 'custom', label: 'Custom (Job catalog)' },
          ]}
          value={formData.planType}
          onChange={(value) => {
            onChange('planType', value);
            if (value === 'custom') onChange('packageTier', undefined);
          }}
        />

        {formData.planType === 'package' && (
          <Select
            label="Package Tier"
            required
            data={[
              { value: '1', label: 'Plan 1 (Basic)' },
              { value: '2', label: 'Plan 2 (Standard)' },
              { value: '3', label: 'Plan 3 (Premium)' },
            ]}
            value={formData.packageTier?.toString() ?? null}
            onChange={(value) => onChange('packageTier', value ? Number(value) : undefined)}
          />
        )}
      </SimpleGrid>
    </>
  );
};


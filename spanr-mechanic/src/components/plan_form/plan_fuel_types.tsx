import { Checkbox, Group, Stack, Text } from '@mantine/core';

interface PlanFuelTypesProps {
  selectedFuelTypes: string[];
  onChange: (fuelTypes: string[]) => void;
}

export const PlanFuelTypes: React.FC<PlanFuelTypesProps> = ({ selectedFuelTypes, onChange }) => {
  const handleToggle = (fuelType: string) => {
    if (selectedFuelTypes.includes(fuelType)) {
      onChange(selectedFuelTypes.filter(ft => ft !== fuelType));
    } else {
      onChange([...selectedFuelTypes, fuelType]);
    }
  };

  return (
    <Stack gap="xs">
      <Text size="sm" fw={500}>Fuel Types</Text>
      <Group>
        <Checkbox
          label="Petrol"
          checked={selectedFuelTypes.includes('petrol')}
          onChange={() => handleToggle('petrol')}
        />
        <Checkbox
          label="Diesel"
          checked={selectedFuelTypes.includes('diesel')}
          onChange={() => handleToggle('diesel')}
        />
      </Group>
    </Stack>
  );
};


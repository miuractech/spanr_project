import { useState } from 'react';
import { 
  Modal, 
  TextInput, 
  Textarea,
  Select, 
  Button, 
  Stack, 
  Group,
  FileInput,
  Image,
} from '@mantine/core';
import { IconUpload } from '@tabler/icons-react';
import type { ServiceFormData } from '../services/services.service';
import type { DbService } from '../types';

interface ServiceFormProps {
  opened: boolean;
  onClose: () => void;
  onSubmit: (data: ServiceFormData, iconFile?: File) => Promise<void>;
  initialData?: DbService;
}

export const ServiceForm: React.FC<ServiceFormProps> = ({
  opened,
  onClose,
  onSubmit,
  initialData,
}) => {
  const [formData, setFormData] = useState<ServiceFormData>({
    name: initialData?.name || '',
    description: initialData?.description || '',
    category: initialData?.category || 'bike',
    iconUrl: initialData?.icon_url || '',
  });

  const [iconFile, setIconFile] = useState<File | null>(null);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async () => {
    setLoading(true);
    try {
      await onSubmit(formData, iconFile || undefined);
      onClose();
      // Reset form
      setFormData({ name: '', description: '', category: 'bike', iconUrl: '' });
      setIconFile(null);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Modal
      opened={opened}
      onClose={onClose}
      title={initialData ? 'Edit Service' : 'Create Service'}
    >
      <Stack>
        <TextInput
          label="Service Name"
          placeholder="Bike Repair"
          required
          value={formData.name}
          onChange={(e) => setFormData({ ...formData, name: e.target.value })}
        />

        <Textarea
          label="Description"
          placeholder="Describe what this service offers..."
          value={formData.description}
          onChange={(e) => setFormData({ ...formData, description: e.target.value })}
          minRows={3}
        />

        <Select
          label="Category"
          required
          data={[
            { value: 'bike', label: 'Bike' },
          ]}
          value={formData.category}
          onChange={(value) => setFormData({ ...formData, category: value as 'bike' })}
        />

        <FileInput
          label="Service Icon"
          placeholder="Upload icon"
          accept="image/*"
          leftSection={<IconUpload size={14} />}
          value={iconFile}
          onChange={setIconFile}
        />

        {(formData.iconUrl || iconFile) && (
          <Image
            src={iconFile ? URL.createObjectURL(iconFile) : formData.iconUrl}
            alt="Service icon"
            h={60}
            w={60}
            fit="contain"
          />
        )}

        <Group justify="flex-end">
          <Button variant="subtle" onClick={onClose}>
            Cancel
          </Button>
          <Button onClick={handleSubmit} loading={loading}>
            {initialData ? 'Update' : 'Create'}
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
};


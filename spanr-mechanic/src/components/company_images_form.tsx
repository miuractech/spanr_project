import { useState } from 'react';
import {
  Stack,
  FileInput,
  Image,
  SimpleGrid,
  Text,
  Group,
  ActionIcon,
  Paper,
} from '@mantine/core';
import { IconUpload, IconX } from '@tabler/icons-react';

interface CompanyImagesFormProps {
  existingImages: string[];
  onImagesChange: (images: File[]) => void;
  onRemoveExisting: (imageUrl: string) => void;
}

export const CompanyImagesForm: React.FC<CompanyImagesFormProps> = ({
  existingImages,
  onImagesChange,
  onRemoveExisting,
}) => {
  const [selectedFiles, setSelectedFiles] = useState<File[]>([]);

  const handleFilesChange = (files: File[]) => {
    setSelectedFiles(files);
    onImagesChange(files);
  };

  const removeFile = (index: number) => {
    const newFiles = selectedFiles.filter((_, i) => i !== index);
    setSelectedFiles(newFiles);
    onImagesChange(newFiles);
  };

  return (
    <Stack gap="md">
      <Text size="sm" c="dimmed">
        Upload company banners or images to showcase your business
      </Text>

      <FileInput
        label="Company Images"
        placeholder="Upload images"
        accept="image/*"
        multiple
        leftSection={<IconUpload size={14} />}
        value={selectedFiles}
        onChange={(files) => handleFilesChange(files || [])}
      />

      {existingImages.length > 0 && (
        <div>
          <Text size="sm" fw={500} mb="xs">
            Existing Images
          </Text>
          <SimpleGrid cols={3}>
            {existingImages.map((imageUrl, index) => (
              <Paper key={`${index}-${imageUrl}`} withBorder p="xs" pos="relative">
                <ActionIcon
                  pos="absolute"
                  top={5}
                  right={5}
                  color="red"
                  size="sm"
                  onClick={() => onRemoveExisting(imageUrl)}
                >
                  <IconX size={14} />
                </ActionIcon>
                <Image src={imageUrl} alt="Company" h={120} fit="cover" />
              </Paper>
            ))}
          </SimpleGrid>
        </div>
      )}

      {selectedFiles.length > 0 && (
        <div>
          <Text size="sm" fw={500} mb="xs">
            New Images (Preview)
          </Text>
          <SimpleGrid cols={3}>
            {selectedFiles.map((file, index) => (
              <Paper key={index} withBorder p="xs" pos="relative">
                <ActionIcon
                  pos="absolute"
                  top={5}
                  right={5}
                  color="red"
                  size="sm"
                  onClick={() => removeFile(index)}
                >
                  <IconX size={14} />
                </ActionIcon>
                <Image
                  src={URL.createObjectURL(file)}
                  alt={`Preview ${index + 1}`}
                  h={120}
                  fit="cover"
                />
              </Paper>
            ))}
          </SimpleGrid>
        </div>
      )}
    </Stack>
  );
};


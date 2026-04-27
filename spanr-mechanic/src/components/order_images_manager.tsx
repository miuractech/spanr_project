import { useState, useEffect } from 'react';
import {
  Stack,
  Title,
  SimpleGrid,
  Image,
  Button,
  Group,
  FileButton,
  Paper,
  Text,
  ActionIcon,
  Loader,
} from '@mantine/core';
import { IconTrash, IconUpload } from '@tabler/icons-react';
import { ordersService } from '../orders/orders.service';
import type { OrderImage } from '../orders/orders.types';

interface OrderImagesManagerProps {
  orderId: string;
}

export const OrderImagesManager: React.FC<OrderImagesManagerProps> = ({ orderId }) => {
  const [beforeImages, setBeforeImages] = useState<OrderImage[]>([]);
  const [afterImages, setAfterImages] = useState<OrderImage[]>([]);
  const [loading, setLoading] = useState(true);
  const [uploading, setUploading] = useState(false);

  useEffect(() => {
    loadImages();
  }, [orderId]);

  const loadImages = async () => {
    try {
      setLoading(true);
      const [before, after] = await Promise.all([
        ordersService.getOrderBeforeImages(orderId),
        ordersService.getOrderAfterImages(orderId),
      ]);
      setBeforeImages(before);
      setAfterImages(after);
    } catch (err) {
      console.error('Failed to load images:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleUploadAfterImage = async (file: File | null) => {
    if (!file) return;

    try {
      setUploading(true);
      await ordersService.uploadAfterImage(orderId, file);
      await loadImages();
    } catch (err) {
      console.error('Failed to upload image:', err);
    } finally {
      setUploading(false);
    }
  };

  const handleDeleteAfterImage = async (imageId: string) => {
    if (!confirm('Are you sure you want to delete this image?')) return;

    try {
      await ordersService.deleteAfterImage(imageId);
      await loadImages();
    } catch (err) {
      console.error('Failed to delete image:', err);
    }
  };

  if (loading) {
    return <Loader />;
  }

  return (
    <Stack gap="xl">
      {beforeImages.length > 0 && (
        <div>
          <Title order={4} mb="md">Before Service Images</Title>
          <SimpleGrid cols={{ base: 2, sm: 3, md: 4 }}>
            {beforeImages.map((img) => (
              <Paper key={img.id} withBorder p="xs">
                <Image
                  src={img.image_url}
                  alt="Before service"
                  h={150}
                  fit="cover"
                />
                <Text size="xs" c="dimmed" mt="xs">
                  {new Date(img.created_at).toLocaleString()}
                </Text>
              </Paper>
            ))}
          </SimpleGrid>
        </div>
      )}

      <div>
        <Group justify="space-between" mb="md">
          <Title order={4}>After Service Images</Title>
          <FileButton onChange={handleUploadAfterImage} accept="image/*">
            {(props) => (
              <Button
                {...props}
                leftSection={<IconUpload size={16} />}
                loading={uploading}
              >
                Upload Image
              </Button>
            )}
          </FileButton>
        </Group>

        {afterImages.length === 0 ? (
          <Text c="dimmed">No after service images uploaded yet.</Text>
        ) : (
          <SimpleGrid cols={{ base: 2, sm: 3, md: 4 }}>
            {afterImages.map((img) => (
              <Paper key={img.id} withBorder p="xs" pos="relative">
                <Image
                  src={img.image_url}
                  alt="After service"
                  h={150}
                  fit="cover"
                />
                <Text size="xs" c="dimmed" mt="xs">
                  {new Date(img.created_at).toLocaleString()}
                </Text>
                <ActionIcon
                  color="red"
                  variant="filled"
                  pos="absolute"
                  top={8}
                  right={8}
                  onClick={() => handleDeleteAfterImage(img.id)}
                >
                  <IconTrash size={16} />
                </ActionIcon>
              </Paper>
            ))}
          </SimpleGrid>
        )}
      </div>
    </Stack>
  );
};


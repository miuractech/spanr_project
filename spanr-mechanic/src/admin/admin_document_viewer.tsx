import { Box, Text, Button, Group } from '@mantine/core';
import { IconFile, IconExternalLink } from '@tabler/icons-react';

export type DocumentKind = 'pdf' | 'image' | 'other';

export function getDocumentKind(fileName: string, url: string): DocumentKind {
  const raw = `${fileName} ${url.split('?')[0]}`.toLowerCase();
  if (raw.includes('.pdf')) return 'pdf';
  if (/\.(jpe?g|png|webp|gif|bmp|heic|heif)(\b|$)/.test(raw)) return 'image';
  return 'other';
}

interface AdminDocumentViewerProps {
  src: string;
  fileName: string;
  title: string;
}

export const AdminDocumentViewer: React.FC<AdminDocumentViewerProps> = ({
  src,
  fileName,
  title,
}) => {
  const kind = getDocumentKind(fileName, src);

  if (kind === 'pdf') {
    return (
      <Box
        style={{
          width: '100%',
          height: 'min(72vh, 820px)',
          borderRadius: 12,
          overflow: 'hidden',
          border: '1px solid #E0E0E0',
          background: '#F2F2F2',
        }}
      >
        <iframe
          title={title}
          src={`${src}#toolbar=1&navpanes=0`}
          style={{ width: '100%', height: '100%', border: 0 }}
        />
      </Box>
    );
  }

  if (kind === 'image') {
    return (
      <Box
        style={{
          width: '100%',
          minHeight: 320,
          maxHeight: 'min(72vh, 820px)',
          borderRadius: 12,
          overflow: 'auto',
          border: '1px solid #E0E0E0',
          background: '#1C1C1C',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          padding: 12,
        }}
      >
        <img
          src={src}
          alt={title}
          style={{
            maxWidth: '100%',
            maxHeight: 'min(70vh, 800px)',
            objectFit: 'contain',
            borderRadius: 8,
          }}
        />
      </Box>
    );
  }

  return (
    <Box
      p="xl"
      style={{
        borderRadius: 12,
        border: '1px solid #E0E0E0',
        background: '#FFFFFF',
        textAlign: 'center',
      }}
    >
      <IconFile size={40} color="#696969" />
      <Text mt="sm" c="#696969" size="sm">
        This file type cannot be previewed here ({fileName || 'unknown'}).
      </Text>
      <Group justify="center" mt="md">
        <Button
          component="a"
          href={src}
          target="_blank"
          rel="noreferrer"
          color="orange"
          variant="light"
          leftSection={<IconExternalLink size={16} />}
        >
          Open in new tab
        </Button>
      </Group>
    </Box>
  );
};

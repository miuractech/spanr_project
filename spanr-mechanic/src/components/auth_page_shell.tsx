import { Box, Container, Paper, Stack, Text, Title } from '@mantine/core';
import type { ReactNode } from 'react';

const inputStyles = {
  input: { minHeight: 52, fontSize: 16 },
  label: { fontSize: 15, fontWeight: 600, marginBottom: 8 },
} as const;

interface AuthPageShellProps {
  title: ReactNode;
  subtitle: string;
  cardMaw?: number;
  children: ReactNode;
}

export function AuthPageShell({ title, subtitle, cardMaw = 520, children }: AuthPageShellProps) {
  return (
    <Box
      style={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        backgroundColor: '#ECECEC',
        padding: 'clamp(1rem, 4vw, 2.5rem)',
      }}
    >
      <Container w="100%" maw={cardMaw} p={0}>
        <Stack align="center" gap="sm" mb={40}>
          <Title
            order={1}
            ta="center"
            style={{
              fontSize: 'clamp(1.875rem, 5vw, 2.375rem)',
              fontWeight: 800,
              color: '#1C1C1C',
              letterSpacing: -0.5,
              lineHeight: 1.2,
            }}
          >
            {title}
          </Title>
          <Text
            c="#696969"
            size="md"
            ta="center"
            fw={500}
            style={{ fontSize: 'clamp(0.9375rem, 2vw, 1.0625rem)' }}
          >
            {subtitle}
          </Text>
        </Stack>

        <Paper
          shadow="md"
          p={{ base: 32, sm: 44 }}
          radius="xl"
          style={{
            border: '1px solid #E8E8E8',
            boxShadow: '0 8px 40px rgba(0, 0, 0, 0.08)',
          }}
        >
          {children}
        </Paper>
      </Container>
    </Box>
  );
}

export { inputStyles };

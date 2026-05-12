import { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../auth/auth.hook';
import {
  TextInput,
  PasswordInput,
  Button,
  Paper,
  Title,
  Container,
  Text,
  Stack,
  Alert,
  Loader,
  Box,
} from '@mantine/core';
import { IconAlertCircle } from '@tabler/icons-react';

const CARD_MAW = 520;

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');
  const { login, user, hasCompany, loading } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    if (!loading && user) {
      navigate(hasCompany ? '/dashboard' : '/onboarding', { replace: true });
    }
  }, [user, hasCompany, loading, navigate]);

  if (loading) {
    return (
      <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh' }}>
        <Loader size="lg" color="orange" />
      </div>
    );
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSubmitting(true);

    try {
      await login(email, password);
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Failed to login';
      setError(message);
      setSubmitting(false);
    }
  };

  const inputStyles = {
    input: { minHeight: 52, fontSize: 16 },
    label: { fontSize: 15, fontWeight: 600, marginBottom: 8 },
  } as const;

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
      <Container w="100%" maw={CARD_MAW} p={0}>
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
            Welcome to{' '}
            <Text component="span" c="#FC8019" inherit>
              SPANR
            </Text>
          </Title>
          <Text c="#696969" size="md" ta="center" fw={500} style={{ fontSize: 'clamp(0.9375rem, 2vw, 1.0625rem)' }}>
            Mechanic Dashboard
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
          <form onSubmit={handleSubmit}>
            <Stack gap={28}>
              {error && (
                <Alert icon={<IconAlertCircle size={22} stroke={1.5} />} color="red" radius="md" p="md">
                  {error}
                </Alert>
              )}

              <TextInput
                label="Email"
                placeholder="your@email.com"
                required
                size="lg"
                styles={inputStyles}
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />

              <PasswordInput
                label="Password"
                placeholder="Your password"
                required
                size="lg"
                styles={inputStyles}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />

              <Button type="submit" fullWidth loading={submitting} color="orange" size="xl" h={56} fz={17} fw={700} mt={4}>
                Sign in
              </Button>

              <Text ta="center" size="md" c="#696969" pt={4}>
                Don't have an account?{' '}
                <Link to="/signup" style={{ fontWeight: 700, color: '#FC8019', textDecoration: 'none' }}>
                  Sign up
                </Link>
              </Text>
            </Stack>
          </form>
        </Paper>
      </Container>
    </Box>
  );
}

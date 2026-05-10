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

  return (
    <Box
      style={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        backgroundColor: '#F2F2F2',
      }}
    >
      <Container size={420}>
        <Stack align="center" mb={32}>
          <Title
            ta="center"
            style={{
              fontSize: 28,
              fontWeight: 800,
              color: '#1C1C1C',
              letterSpacing: -0.5,
            }}
          >
            Welcome to{' '}
            <Text component="span" c="#FC8019" inherit>
              SPANR
            </Text>
          </Title>
          <Text c="#696969" size="sm" ta="center">
            Mechanic Dashboard
          </Text>
        </Stack>

        <Paper shadow="sm" p={32} radius="lg" style={{ border: '1px solid #E0E0E0' }}>
          <form onSubmit={handleSubmit}>
            <Stack>
              {error && (
                <Alert icon={<IconAlertCircle size={16} />} color="red" radius="md">
                  {error}
                </Alert>
              )}

              <TextInput
                label="Email"
                placeholder="your@email.com"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />

              <PasswordInput
                label="Password"
                placeholder="Your password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />

              <Button type="submit" fullWidth loading={submitting} color="orange" size="md">
                Sign in
              </Button>

              <Text ta="center" size="sm" c="#696969">
                Don't have an account?{' '}
                <Link to="/signup" style={{ fontWeight: 600, color: '#FC8019', textDecoration: 'none' }}>
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

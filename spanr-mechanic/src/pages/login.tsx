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
  Loader
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
        <Loader size="lg" />
      </div>
    );
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSubmitting(true);

    try {
      await login(email, password);
      // Navigation will happen via useEffect
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Failed to login';
      setError(message);
      setSubmitting(false);
    }
  };

  return (
    <Container size={420} my={100}>
      <Title ta="center" mb="md" c="#FF6B35">
        Welcome to SPANR
      </Title>
      <Text c="dimmed" size="sm" ta="center" mb={30}>
        Mechanic Dashboard
      </Text>

      <Paper withBorder shadow="md" p={30} radius="md" style={{ backgroundColor: '#FFFFFF' }}>
        <form onSubmit={handleSubmit}>
          <Stack>
            {error && (
              <Alert icon={<IconAlertCircle size={16} />} color="red">
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

            <Button type="submit" fullWidth loading={submitting} color="orange">
              Sign in
            </Button>

            <Text ta="center" size="sm">
              Don't have an account?{' '}
              <Link to="/signup" style={{ fontWeight: 600, color: '#FF6B35', textDecoration: 'none' }}>
                Sign up
              </Link>
            </Text>
          </Stack>
        </form>
      </Paper>
    </Container>
  );
}


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

export default function SignupPage() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');
  const { signUp, user, hasCompany, loading } = useAuth();
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

    if (password !== confirmPassword) {
      setError('Passwords do not match');
      return;
    }

    if (password.length < 6) {
      setError('Password must be at least 6 characters');
      return;
    }

    setSubmitting(true);

    try {
      await signUp(email, password, name);
      // Navigation will happen via useEffect
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Failed to create account';
      setError(message);
      setSubmitting(false);
    }
  };

  return (
    <Container size={420} my={100}>
      <Title ta="center" mb="md" c="#FF6B35">
        Join SPANR
      </Title>
      <Text c="dimmed" size="sm" ta="center" mb={30}>
        Create your mechanic business account
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
              label="Full Name"
              placeholder="John Doe"
              required
              value={name}
              onChange={(e) => setName(e.target.value)}
            />

            <TextInput
              label="Email"
              placeholder="your@email.com"
              required
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />

            <PasswordInput
              label="Password"
              placeholder="At least 6 characters"
              required
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />

            <PasswordInput
              label="Confirm Password"
              placeholder="Repeat your password"
              required
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
            />

            <Button type="submit" fullWidth loading={submitting} color="orange">
              Create Account
            </Button>

            <Text ta="center" size="sm">
              Already have an account?{' '}
              <Link to="/login" style={{ fontWeight: 600, color: '#FF6B35', textDecoration: 'none' }}>
                Sign in
              </Link>
            </Text>
          </Stack>
        </form>
      </Paper>
    </Container>
  );
}


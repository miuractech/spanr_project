import { useEffect, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../auth/auth.hook';
import { getAuthErrorMessage, isEmailNotConfirmedError } from '../auth/auth.util';
import { AuthPageShell, inputStyles } from '../components/auth_page_shell';
import {
  TextInput,
  PasswordInput,
  Button,
  Text,
  Stack,
  Alert,
  Loader,
  Anchor,
} from '@mantine/core';
import { useForm } from '@mantine/form';
import { IconAlertCircle, IconMailCheck } from '@tabler/icons-react';

export default function LoginPage() {
  const [submitting, setSubmitting] = useState(false);
  const [resending, setResending] = useState(false);
  const [error, setError] = useState('');
  const [resendMessage, setResendMessage] = useState('');
  const [unverifiedEmail, setUnverifiedEmail] = useState('');
  const { login, user, hasCompany, loading, resendVerificationEmail } = useAuth();
  const navigate = useNavigate();

  const form = useForm({
    initialValues: { email: '', password: '' },
    validate: {
      email: (value) => {
        if (!value.trim()) return 'Email is required';
        if (!/^\S+@\S+\.\S+$/.test(value)) return 'Enter a valid email address';
        return null;
      },
      password: (value) => (value ? null : 'Password is required'),
    },
  });

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

  const handleResend = async () => {
    if (!unverifiedEmail) return;
    setResending(true);
    setResendMessage('');
    try {
      await resendVerificationEmail(unverifiedEmail);
      setResendMessage('Verification email sent. Check your inbox.');
    } catch (err) {
      setResendMessage(getAuthErrorMessage(err, 'Failed to resend verification email'));
    } finally {
      setResending(false);
    }
  };

  const handleSubmit = form.onSubmit(async (values) => {
    setError('');
    setResendMessage('');
    setUnverifiedEmail('');
    setSubmitting(true);

    try {
      await login(values.email, values.password);
    } catch (err) {
      if (isEmailNotConfirmedError(err)) {
        setUnverifiedEmail(values.email);
      }
      setError(getAuthErrorMessage(err, 'Failed to login'));
      setSubmitting(false);
    }
  });

  return (
    <AuthPageShell
      title={
        <>
          Welcome to{' '}
          <Text component="span" c="#FC8019" inherit>
            SPANR
          </Text>
        </>
      }
      subtitle="Mechanic Dashboard"
    >
      <form onSubmit={handleSubmit} noValidate>
        <Stack gap={28}>
          {error && (
            <Alert icon={<IconAlertCircle size={22} stroke={1.5} />} color="red" radius="md" p="md">
              {error}
            </Alert>
          )}

          {resendMessage && (
            <Alert icon={<IconMailCheck size={22} stroke={1.5} />} color="green" radius="md" p="md">
              {resendMessage}
            </Alert>
          )}

          <TextInput
            label="Email"
            placeholder="your@email.com"
            type="email"
            withAsterisk
            size="lg"
            styles={inputStyles}
            {...form.getInputProps('email')}
          />

          <Stack gap={8}>
            <PasswordInput
              label="Password"
              placeholder="Your password"
              withAsterisk
              size="lg"
              styles={inputStyles}
              {...form.getInputProps('password')}
            />
            <Text ta="right">
              <Anchor component={Link} to="/forgot-password" size="sm" c="#FC8019" fw={600}>
                Forgot password?
              </Anchor>
            </Text>
          </Stack>

          {unverifiedEmail && (
            <Button variant="light" color="orange" loading={resending} onClick={handleResend}>
              Resend verification email
            </Button>
          )}

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
    </AuthPageShell>
  );
}

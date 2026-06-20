import { useState } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../auth/auth.hook';
import { getAuthErrorMessage } from '../auth/auth.util';
import { AuthPageShell, inputStyles } from '../components/auth_page_shell';
import { TextInput, Button, Text, Stack, Alert } from '@mantine/core';
import { useForm } from '@mantine/form';
import { IconAlertCircle, IconMailCheck } from '@tabler/icons-react';

export default function ForgotPasswordPage() {
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');
  const [sent, setSent] = useState(false);
  const { resetPasswordForEmail } = useAuth();

  const form = useForm({
    initialValues: { email: '' },
    validate: {
      email: (value) => {
        if (!value.trim()) return 'Email is required';
        if (!/^\S+@\S+\.\S+$/.test(value)) return 'Enter a valid email address';
        return null;
      },
    },
  });

  const handleSubmit = form.onSubmit(async (values) => {
    setError('');
    setSubmitting(true);

    try {
      await resetPasswordForEmail(values.email);
      setSent(true);
    } catch (err) {
      setError(getAuthErrorMessage(err, 'Failed to send reset email'));
    } finally {
      setSubmitting(false);
    }
  });

  return (
    <AuthPageShell
      title={
        <>
          Reset{' '}
          <Text component="span" c="#FC8019" inherit>
            password
          </Text>
        </>
      }
      subtitle="We'll email you a reset link"
    >
      {sent ? (
        <Stack gap={24}>
          <Alert icon={<IconMailCheck size={22} stroke={1.5} />} color="green" radius="md" p="md">
            If an account exists for that email, we sent a password reset link.
          </Alert>
          <Button component={Link} to="/login" fullWidth color="orange" size="xl" h={56} fz={17} fw={700}>
            Back to sign in
          </Button>
        </Stack>
      ) : (
        <form onSubmit={handleSubmit} noValidate>
          <Stack gap={24}>
            {error && (
              <Alert icon={<IconAlertCircle size={22} stroke={1.5} />} color="red" radius="md" p="md">
                {error}
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

            <Button type="submit" fullWidth loading={submitting} color="orange" size="xl" h={56} fz={17} fw={700}>
              Send reset link
            </Button>

            <Text ta="center" size="md" c="#696969">
              Remember your password?{' '}
              <Link to="/login" style={{ fontWeight: 700, color: '#FC8019', textDecoration: 'none' }}>
                Sign in
              </Link>
            </Text>
          </Stack>
        </form>
      )}
    </AuthPageShell>
  );
}

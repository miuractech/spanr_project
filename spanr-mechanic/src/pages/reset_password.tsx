import { useEffect, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../auth/auth.hook';
import { getAuthErrorMessage } from '../auth/auth.util';
import { AuthPageShell, inputStyles } from '../components/auth_page_shell';
import { isPasswordStrongEnough } from '../core/password.util';
import { PasswordStrengthIndicator } from '../components/password_strength_indicator';
import supabase from '../supabaseconfig';
import { PasswordInput, Button, Text, Stack, Alert, Loader } from '@mantine/core';
import { useForm } from '@mantine/form';
import { IconAlertCircle, IconCircleCheck } from '@tabler/icons-react';

export default function ResetPasswordPage() {
  const [ready, setReady] = useState(false);
  const [checking, setChecking] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState(false);
  const { updatePassword } = useAuth();
  const navigate = useNavigate();

  const form = useForm({
    initialValues: { password: '', confirmPassword: '' },
    validate: {
      password: (value) => {
        if (!value) return 'Password is required';
        if (!isPasswordStrongEnough(value)) {
          return 'Use 8+ characters with upper, lower, number, and special character';
        }
        return null;
      },
      confirmPassword: (value, values) => {
        if (!value) return 'Please confirm your password';
        if (value !== values.password) return 'Passwords do not match';
        return null;
      },
    },
  });

  useEffect(() => {
    let mounted = true;

    const { data: { subscription } } = supabase.auth.onAuthStateChange((event) => {
      if (!mounted) return;
      if (event === 'PASSWORD_RECOVERY' || event === 'SIGNED_IN') {
        setReady(true);
        setChecking(false);
      }
    });

    supabase.auth.getSession().then(({ data: { session } }) => {
      if (!mounted) return;
      if (session) {
        setReady(true);
      }
      setChecking(false);
    });

    return () => {
      mounted = false;
      subscription.unsubscribe();
    };
  }, []);

  const handleSubmit = form.onSubmit(async (values) => {
    setError('');
    setSubmitting(true);

    try {
      await updatePassword(values.password);
      await supabase.auth.signOut();
      setSuccess(true);
      setTimeout(() => navigate('/login', { replace: true }), 2000);
    } catch (err) {
      setError(getAuthErrorMessage(err, 'Failed to update password'));
      setSubmitting(false);
    }
  });

  if (checking) {
    return (
      <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh' }}>
        <Loader size="lg" color="orange" />
      </div>
    );
  }

  if (!ready) {
    return (
      <AuthPageShell
        title={
          <>
            Invalid{' '}
            <Text component="span" c="#FC8019" inherit>
              link
            </Text>
          </>
        }
        subtitle="This reset link is expired or invalid"
      >
        <Stack gap={24}>
          <Alert icon={<IconAlertCircle size={22} stroke={1.5} />} color="red" radius="md" p="md">
            Request a new password reset link and try again.
          </Alert>
          <Button component={Link} to="/forgot-password" fullWidth color="orange" size="xl" h={56} fz={17} fw={700}>
            Request new link
          </Button>
        </Stack>
      </AuthPageShell>
    );
  }

  if (success) {
    return (
      <AuthPageShell
        title={
          <>
            Password{' '}
            <Text component="span" c="#FC8019" inherit>
              updated
            </Text>
          </>
        }
        subtitle="You can now sign in with your new password"
      >
        <Alert icon={<IconCircleCheck size={22} stroke={1.5} />} color="green" radius="md" p="md">
          Password updated successfully. Redirecting to sign in...
        </Alert>
      </AuthPageShell>
    );
  }

  return (
    <AuthPageShell
      title={
        <>
          Set new{' '}
          <Text component="span" c="#FC8019" inherit>
            password
          </Text>
        </>
      }
      subtitle="Choose a strong password for your account"
      cardMaw={560}
    >
      <form onSubmit={handleSubmit} noValidate>
        <Stack gap={24}>
          {error && (
            <Alert icon={<IconAlertCircle size={22} stroke={1.5} />} color="red" radius="md" p="md">
              {error}
            </Alert>
          )}

          <PasswordInput
            label="New Password"
            placeholder="Create a strong password"
            withAsterisk
            size="lg"
            styles={inputStyles}
            {...form.getInputProps('password')}
          />

          <PasswordStrengthIndicator password={form.values.password} />

          <PasswordInput
            label="Confirm Password"
            placeholder="Repeat your password"
            withAsterisk
            size="lg"
            styles={inputStyles}
            {...form.getInputProps('confirmPassword')}
          />

          <Button type="submit" fullWidth loading={submitting} color="orange" size="xl" h={56} fz={17} fw={700}>
            Update password
          </Button>
        </Stack>
      </form>
    </AuthPageShell>
  );
}

import { useEffect, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../auth/auth.hook';
import { getAuthErrorMessage } from '../auth/auth.util';
import { AuthPageShell, inputStyles } from '../components/auth_page_shell';
import { PasswordStrengthIndicator } from '../components/password_strength_indicator';
import { isPasswordStrongEnough } from '../core/password.util';
import {
  TextInput,
  PasswordInput,
  Button,
  Text,
  Stack,
  Alert,
  Loader,
} from '@mantine/core';
import { useForm } from '@mantine/form';
import { IconAlertCircle, IconMailCheck } from '@tabler/icons-react';

export default function SignupPage() {
  const [submitting, setSubmitting] = useState(false);
  const [resending, setResending] = useState(false);
  const [error, setError] = useState('');
  const [resendMessage, setResendMessage] = useState('');
  const [verificationSent, setVerificationSent] = useState(false);
  const [signupEmail, setSignupEmail] = useState('');
  const { signUp, user, hasCompany, loading, resendVerificationEmail } = useAuth();
  const navigate = useNavigate();

  const form = useForm({
    initialValues: {
      name: '',
      email: '',
      password: '',
      confirmPassword: '',
    },
    validate: {
      name: (value) => (value.trim() ? null : 'Full name is required'),
      email: (value) => {
        if (!value.trim()) return 'Email is required';
        if (!/^\S+@\S+\.\S+$/.test(value)) return 'Enter a valid email address';
        return null;
      },
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
    if (verificationSent) return;
    if (!loading && user) {
      navigate(hasCompany ? '/dashboard' : '/onboarding', { replace: true });
    }
  }, [user, hasCompany, loading, navigate, verificationSent]);

  useEffect(() => {
    const pendingEmail = sessionStorage.getItem('spanr_pending_verification_email');
    if (pendingEmail) {
      setSignupEmail(pendingEmail);
      setVerificationSent(true);
    }
  }, []);

  if (loading && !verificationSent) {
    return (
      <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh' }}>
        <Loader size="lg" color="orange" />
      </div>
    );
  }

  const handleStartOver = () => {
    sessionStorage.removeItem('spanr_pending_verification_email');
    setVerificationSent(false);
    setSignupEmail('');
    setResendMessage('');
    setError('');
    form.reset();
  };

  const handleResend = async () => {
    if (!signupEmail) return;
    setResending(true);
    setResendMessage('');
    try {
      await resendVerificationEmail(signupEmail);
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
    setSubmitting(true);

    try {
      await signUp(values.email, values.password, values.name.trim());
      sessionStorage.setItem('spanr_pending_verification_email', values.email);
      setSignupEmail(values.email);
      setVerificationSent(true);
      setSubmitting(false);
    } catch (err) {
      setError(getAuthErrorMessage(err, 'Failed to create account'));
      setSubmitting(false);
    }
  });

  if (verificationSent) {
    return (
      <AuthPageShell
        title={
          <>
            Check your{' '}
            <Text component="span" c="#FC8019" inherit>
              email
            </Text>
          </>
        }
        subtitle="Verify your email to start onboarding"
        cardMaw={560}
      >
        <Stack gap={24}>
          <Alert icon={<IconMailCheck size={22} stroke={1.5} />} color="green" radius="md" p="md">
            Account created. We sent a verification link to <strong>{signupEmail}</strong>. Click the link in
            your email to verify your address — you'll then be taken to complete your business setup.
          </Alert>

          {resendMessage && (
            <Alert icon={<IconMailCheck size={22} stroke={1.5} />} color="blue" radius="md" p="md">
              {resendMessage}
            </Alert>
          )}

          <Button variant="light" color="orange" loading={resending} onClick={handleResend}>
            Resend verification email
          </Button>

          <Button variant="subtle" color="gray" onClick={handleStartOver}>
            Use a different email
          </Button>

          <Text ta="center" size="sm" c="#696969">
            Already verified?{' '}
            <Link to="/login" style={{ fontWeight: 700, color: '#FC8019', textDecoration: 'none' }}>
              Sign in
            </Link>
          </Text>
        </Stack>
      </AuthPageShell>
    );
  }

  return (
    <AuthPageShell
      title={
        <>
          Join{' '}
          <Text component="span" c="#FC8019" inherit>
            SPANR
          </Text>
        </>
      }
      subtitle="Create your mechanic business account"
      cardMaw={560}
    >
      <form onSubmit={handleSubmit} noValidate>
        <Stack gap={24}>
          {error && (
            <Alert icon={<IconAlertCircle size={22} stroke={1.5} />} color="red" radius="md" p="md">
              {error}
            </Alert>
          )}

          <TextInput
            label="Full Name"
            placeholder="John Doe"
            withAsterisk
            size="lg"
            styles={inputStyles}
            {...form.getInputProps('name')}
          />

          <TextInput
            label="Email"
            placeholder="your@email.com"
            type="email"
            withAsterisk
            size="lg"
            styles={inputStyles}
            {...form.getInputProps('email')}
          />

          <PasswordInput
            label="Password"
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

          <Button type="submit" fullWidth loading={submitting} color="orange" size="xl" h={56} fz={17} fw={700} mt={8}>
            Create Account
          </Button>

          <Text ta="center" size="md" c="#696969" pt={4}>
            Already have an account?{' '}
            <Link to="/login" style={{ fontWeight: 700, color: '#FC8019', textDecoration: 'none' }}>
              Sign in
            </Link>
          </Text>
        </Stack>
      </form>
    </AuthPageShell>
  );
}

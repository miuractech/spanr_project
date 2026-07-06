import { useEffect, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../auth/auth.hook';
import { getAuthErrorMessage } from '../auth/auth.util';
import { AuthPageShell, inputStyles } from '../components/auth_page_shell';
import {
  TextInput,
  Button,
  Text,
  Stack,
  Alert,
  Loader,
  PinInput,
  Group,
} from '@mantine/core';
import { useForm } from '@mantine/form';
import { IconAlertCircle, IconPhone, IconArrowLeft } from '@tabler/icons-react';

type Step = 'phone' | 'otp';

export default function LoginPage() {
  const [step, setStep] = useState<Step>('phone');
  const [phone, setPhone] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');
  const { sendOtp, verifyOtp, user, hasCompany, loading } = useAuth();
  const navigate = useNavigate();

  const phoneForm = useForm({
    initialValues: { phone: '' },
    validate: {
      phone: (v) => {
        const digits = v.replace(/\D/g, '');
        return digits.length >= 10 ? null : 'Enter a valid 10-digit mobile number';
      },
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

  const handleSendOtp = phoneForm.onSubmit(async (values) => {
    setError('');
    setSubmitting(true);
    try {
      await sendOtp(values.phone);
      setPhone(values.phone);
      setStep('otp');
    } catch (err) {
      setError(getAuthErrorMessage(err, 'Failed to send OTP. Try again.'));
    } finally {
      setSubmitting(false);
    }
  });

  const handleVerifyOtp = async (token: string) => {
    if (token.length < 6) return;
    setError('');
    setSubmitting(true);
    try {
      await verifyOtp(phone, token);
      // navigation handled by useEffect above
    } catch (err) {
      setError(getAuthErrorMessage(err, 'Invalid OTP. Please try again.'));
      setSubmitting(false);
    }
  };

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
      subtitle="Shop Owner Dashboard"
    >
      <Stack gap={28}>
        {error && (
          <Alert icon={<IconAlertCircle size={22} stroke={1.5} />} color="red" radius="md" p="md">
            {error}
          </Alert>
        )}

        {step === 'phone' && (
          <form onSubmit={handleSendOtp} noValidate>
            <Stack gap={24}>
              <TextInput
                label="Mobile Number"
                placeholder="98765 43210"
                leftSection={<IconPhone size={18} />}
                description="We'll send a one-time code to this number"
                size="lg"
                styles={inputStyles}
                {...phoneForm.getInputProps('phone')}
              />
              <Button type="submit" fullWidth loading={submitting} color="orange" size="xl" h={56} fz={17} fw={700}>
                Send OTP
              </Button>
              <Text ta="center" size="md" c="#696969">
                New here?{' '}
                <Link to="/signup" style={{ fontWeight: 700, color: '#FC8019', textDecoration: 'none' }}>
                  Create account
                </Link>
              </Text>
            </Stack>
          </form>
        )}

        {step === 'otp' && (
          <Stack gap={24} align="center">
            <Text size="sm" c="#696969" ta="center">
              Enter the 6-digit code sent to <strong>{phone}</strong>
            </Text>
            <PinInput
              length={6}
              type="number"
              size="lg"
              onComplete={handleVerifyOtp}
              disabled={submitting}
              autoFocus
            />
            {submitting && <Loader size="sm" color="orange" />}
            <Group gap="xs">
              <Button
                variant="subtle"
                color="gray"
                leftSection={<IconArrowLeft size={16} />}
                onClick={() => { setStep('phone'); setError(''); }}
                size="sm"
              >
                Change number
              </Button>
              <Button
                variant="subtle"
                color="orange"
                size="sm"
                onClick={() => { setError(''); sendOtp(phone).catch(() => {}); }}
              >
                Resend OTP
              </Button>
            </Group>
          </Stack>
        )}
      </Stack>
    </AuthPageShell>
  );
}

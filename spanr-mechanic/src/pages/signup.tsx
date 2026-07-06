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

type Step = 'info' | 'otp';

export default function SignupPage() {
  const [step, setStep] = useState<Step>('info');
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');
  const [signupPhone, setSignupPhone] = useState('');
  const { sendOtp, verifyOtp, user, hasCompany, loading } = useAuth();
  const navigate = useNavigate();

  const infoForm = useForm({
    initialValues: { name: '', phone: '' },
    validate: {
      name: (v) => (v.trim().length >= 2 ? null : 'Enter your full name'),
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

  const handleSendOtp = infoForm.onSubmit(async (values) => {
    setError('');
    setSubmitting(true);
    try {
      // Store name in sessionStorage to use during createCompany
      sessionStorage.setItem('spanr_signup_name', values.name.trim());
      await sendOtp(values.phone);
      setSignupPhone(values.phone);
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
      await verifyOtp(signupPhone, token);
      // navigation handled by useEffect
    } catch (err) {
      setError(getAuthErrorMessage(err, 'Invalid OTP. Please try again.'));
      setSubmitting(false);
    }
  };

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
      subtitle="Register your mechanic shop"
      cardMaw={500}
    >
      <Stack gap={28}>
        {error && (
          <Alert icon={<IconAlertCircle size={22} stroke={1.5} />} color="red" radius="md" p="md">
            {error}
          </Alert>
        )}

        {step === 'info' && (
          <form onSubmit={handleSendOtp} noValidate>
            <Stack gap={24}>
              <TextInput
                label="Your Name"
                placeholder="Ravi Kumar"
                withAsterisk
                size="lg"
                styles={inputStyles}
                {...infoForm.getInputProps('name')}
              />
              <TextInput
                label="Mobile Number"
                placeholder="98765 43210"
                leftSection={<IconPhone size={18} />}
                description="This becomes your login credential"
                withAsterisk
                size="lg"
                styles={inputStyles}
                {...infoForm.getInputProps('phone')}
              />
              <Button type="submit" fullWidth loading={submitting} color="orange" size="xl" h={56} fz={17} fw={700} mt={8}>
                Send OTP
              </Button>
              <Text ta="center" size="md" c="#696969">
                Already have an account?{' '}
                <Link to="/login" style={{ fontWeight: 700, color: '#FC8019', textDecoration: 'none' }}>
                  Sign in
                </Link>
              </Text>
            </Stack>
          </form>
        )}

        {step === 'otp' && (
          <Stack gap={24} align="center">
            <Text size="sm" c="#696969" ta="center">
              Enter the 6-digit code sent to <strong>{signupPhone}</strong>
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
                onClick={() => { setStep('info'); setError(''); }}
                size="sm"
              >
                Back
              </Button>
              <Button
                variant="subtle"
                color="orange"
                size="sm"
                onClick={() => { setError(''); sendOtp(signupPhone).catch(() => {}); }}
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

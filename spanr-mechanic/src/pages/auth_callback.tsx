import { useEffect, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../auth/auth.hook';
import { AuthPageShell } from '../components/auth_page_shell';
import { Alert, Button, Loader, Text } from '@mantine/core';
import { IconAlertCircle, IconCircleCheck } from '@tabler/icons-react';

export default function AuthCallbackPage() {
  const [error, setError] = useState('');
  const { user, hasCompany, loading } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    if (!loading && user) {
      sessionStorage.removeItem('spanr_pending_verification_email');
      navigate(hasCompany ? '/dashboard' : '/onboarding', { replace: true });
    }
  }, [user, hasCompany, loading, navigate]);

  useEffect(() => {
    const timeout = window.setTimeout(() => {
      if (!loading && !user) {
        setError('Could not verify your email. The link may have expired.');
      }
    }, 5000);

    return () => window.clearTimeout(timeout);
  }, [loading, user]);

  if (loading) {
    return (
      <AuthPageShell
        title={
          <>
            Verifying{' '}
            <Text component="span" c="#FC8019" inherit>
              email
            </Text>
          </>
        }
        subtitle="Please wait"
      >
        <div style={{ display: 'flex', justifyContent: 'center', padding: '1rem 0' }}>
          <Loader size="lg" color="orange" />
        </div>
      </AuthPageShell>
    );
  }

  if (error) {
    return (
      <AuthPageShell
        title={
          <>
            Verification{' '}
            <Text component="span" c="#FC8019" inherit>
              failed
            </Text>
          </>
        }
        subtitle="We couldn't confirm your email"
      >
        <Alert icon={<IconAlertCircle size={22} stroke={1.5} />} color="red" radius="md" p="md" mb="md">
          {error}
        </Alert>
        <Button component={Link} to="/login" fullWidth color="orange" size="xl" h={56} fz={17} fw={700}>
          Back to sign in
        </Button>
      </AuthPageShell>
    );
  }

  return (
    <AuthPageShell
      title={
        <>
          Email{' '}
          <Text component="span" c="#FC8019" inherit>
            verified
          </Text>
        </>
      }
      subtitle="Continue to business setup"
    >
      <Alert icon={<IconCircleCheck size={22} stroke={1.5} />} color="green" radius="md" p="md">
        Email verified successfully. Taking you to onboarding...
      </Alert>
    </AuthPageShell>
  );
}

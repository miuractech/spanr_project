import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { TextInput, PasswordInput, Button, Stack, Alert, Text } from '@mantine/core';
import { IconAlertCircle, IconMail } from '@tabler/icons-react';
import { adminService } from './admin.service';
import { AuthPageShell, inputStyles } from '../components/auth_page_shell';

export default function AdminLoginPage() {
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [needsClaim, setNeedsClaim] = useState(false);

  const handleSignIn = async () => {
    setError('');
    setLoading(true);
    try {
      await adminService.signIn(email, password);
      const isAdmin = await adminService.amISuperAdmin();
      if (isAdmin) {
        navigate('/admin', { replace: true });
        return;
      }
      const anyAdminExists = await adminService.hasAnyAdmin();
      if (!anyAdminExists) {
        setNeedsClaim(true);
      } else {
        setError('This account is not registered as a SPANR admin.');
        await adminService.signOut();
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Sign in failed');
    } finally {
      setLoading(false);
    }
  };

  const handleClaim = async () => {
    setError('');
    setLoading(true);
    try {
      await adminService.claimFirstAdmin(email);
      navigate('/admin', { replace: true });
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Could not claim admin access');
    } finally {
      setLoading(false);
    }
  };

  return (
    <AuthPageShell
      title={
        <>
          SPANR{' '}
          <Text component="span" c="#FC8019" inherit>
            Admin
          </Text>
        </>
      }
      subtitle="Shop KYC approval desk"
    >
      <Stack gap={24}>
        {error && (
          <Alert icon={<IconAlertCircle size={22} stroke={1.5} />} color="red" radius="md" p="md">
            {error}
          </Alert>
        )}

        {needsClaim ? (
          <>
            <Alert color="orange" variant="light" radius="md">
              No admin exists yet. Claim admin access for <strong>{email}</strong>?
            </Alert>
            <Button onClick={handleClaim} loading={loading} color="orange" size="xl" h={56} fz={17} fw={700} fullWidth>
              Claim admin access
            </Button>
          </>
        ) : (
          <>
            <TextInput
              label="Email"
              placeholder="admin@spanr.in"
              leftSection={<IconMail size={18} />}
              size="lg"
              styles={inputStyles}
              value={email}
              onChange={(e) => setEmail(e.currentTarget.value)}
            />
            <PasswordInput
              label="Password"
              size="lg"
              styles={inputStyles}
              value={password}
              onChange={(e) => setPassword(e.currentTarget.value)}
              onKeyDown={(e) => e.key === 'Enter' && void handleSignIn()}
            />
            <Button
              onClick={() => void handleSignIn()}
              loading={loading}
              color="orange"
              size="xl"
              h={56}
              fz={17}
              fw={700}
              fullWidth
            >
              Sign in
            </Button>
          </>
        )}
      </Stack>
    </AuthPageShell>
  );
}

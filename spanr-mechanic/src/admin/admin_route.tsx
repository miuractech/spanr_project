import { useEffect, useState } from 'react';
import { Navigate } from 'react-router-dom';
import { Loader, Center, Text, Button, Stack } from '@mantine/core';
import { adminService } from './admin.service';

export const AdminRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [status, setStatus] = useState<'checking' | 'allowed' | 'denied' | 'error'>('checking');

  useEffect(() => {
    let mounted = true;
    const timeout = window.setTimeout(() => {
      if (mounted) setStatus((s) => (s === 'checking' ? 'error' : s));
    }, 10000);

    adminService
      .amISuperAdmin()
      .then((isAdmin) => {
        if (mounted) setStatus(isAdmin ? 'allowed' : 'denied');
      })
      .catch(() => {
        if (mounted) setStatus('denied');
      });

    return () => {
      mounted = false;
      window.clearTimeout(timeout);
    };
  }, []);

  if (status === 'checking') {
    return (
      <Center style={{ height: '100vh', backgroundColor: '#F2F2F2' }}>
        <Loader size="lg" color="orange" />
      </Center>
    );
  }

  if (status === 'error') {
    return (
      <Center style={{ height: '100vh', backgroundColor: '#F2F2F2' }}>
        <Stack align="center" gap="sm">
          <Text>Admin check timed out. Run migration 051 in the SQL editor, then retry.</Text>
          <Button component="a" href="/admin/login" color="orange">
            Back to admin login
          </Button>
        </Stack>
      </Center>
    );
  }

  if (status === 'denied') {
    return <Navigate to="/admin/login" replace />;
  }

  return <>{children}</>;
};

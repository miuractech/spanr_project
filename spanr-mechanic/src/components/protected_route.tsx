import { Navigate } from 'react-router-dom';
import { useAuth } from '../auth/auth.hook';
import { Loader } from '@mantine/core';

interface ProtectedRouteProps {
  children: React.ReactNode;
  requireCompany?: boolean;
}

export const ProtectedRoute: React.FC<ProtectedRouteProps> = ({
  children,
  requireCompany = false
}) => {
  const { user, loading, hasCompany } = useAuth();

  if (loading) {
    return (
      <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh' }}>
        <Loader size="lg" />
      </div>
    );
  }

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  if (requireCompany && !hasCompany) {
    return <Navigate to="/onboarding" replace />;
  }

  return <>{children}</>;
};


import { Navigate } from 'react-router-dom';
import { useAuth } from '../auth/auth.hook';
import { Loader } from '@mantine/core';
import supabase from '../supabaseconfig';
import { isEmailVerified } from '../auth/auth.util';
import { useEffect } from 'react';

interface ProtectedRouteProps {
  children: React.ReactNode;
  requireCompany?: boolean;
}

export const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ 
  children, 
  requireCompany = false 
}) => {
  const { user, loading, hasCompany } = useAuth();

  useEffect(() => {
    if (loading || user) return;
    supabase.auth.getUser().then(({ data: { user: authUser } }) => {
      if (authUser && !isEmailVerified(authUser)) {
        supabase.auth.signOut();
      }
    });
  }, [loading, user]);

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


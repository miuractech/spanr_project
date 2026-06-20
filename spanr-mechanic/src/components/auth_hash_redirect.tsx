import { useEffect } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';

export function AuthHashRedirect() {
  const location = useLocation();
  const navigate = useNavigate();

  useEffect(() => {
    const hash = window.location.hash;
    if (!hash.includes('access_token')) return;
    if (location.pathname === '/auth/callback') return;

    navigate(`/auth/callback${hash}`, { replace: true });
  }, [location.pathname, navigate]);

  return null;
}

import { createContext, useEffect, useState } from 'react';
import { authService, authUsersEqual, type AuthUser } from './auth.service';

interface AuthContextType {
  user: AuthUser | null;
  loading: boolean;
  signUp: (email: string, password: string, name: string) => Promise<void>;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  refreshUser: () => Promise<void>;
  hasCompany: boolean;
}

export const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let mounted = true;
    const authSubscription = authService.onAuthStateChange((newUser) => {
      if (!mounted) return;
      setUser((prev) => (authUsersEqual(prev, newUser) ? prev : newUser));
      setLoading(false);
    });

    return () => {
      mounted = false;
      authSubscription.data.subscription.unsubscribe();
    };
  }, []);

  const signUp = async (email: string, password: string, name: string) => {
    setLoading(true);
    try {
      await authService.signUp({ email, password, name });
    } catch (err) {
      setLoading(false);
      throw err;
    }
  };

  const login = async (email: string, password: string) => {
    setLoading(true);
    try {
      await authService.login({ email, password });
    } catch (err) {
      setLoading(false);
      throw err;
    }
  };

  const logout = async () => {
    await authService.logout();
    setUser(null);
  };

  const refreshUser = async () => {
    try {
      const currentUser = await authService.getCurrentUser();
      setUser((prev) => (authUsersEqual(prev, currentUser) ? prev : currentUser));
    } catch (error) {
      console.error('Failed to refresh user:', error);
    }
  };

  const hasCompany = !!user?.companyId;

  return (
    <AuthContext.Provider value={{ user, loading, signUp, login, logout, refreshUser, hasCompany }}>
      {children}
    </AuthContext.Provider>
  );
};

import { createContext, useEffect, useRef, useState } from 'react';
import { authService, authUsersEqual, type AuthUser } from './auth.service';

interface SignUpResult {
  requiresVerification: boolean;
}

interface AuthContextType {
  user: AuthUser | null;
  loading: boolean;
  signUp: (email: string, password: string, name: string) => Promise<SignUpResult>;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  refreshUser: () => Promise<void>;
  resetPasswordForEmail: (email: string) => Promise<void>;
  updatePassword: (password: string) => Promise<void>;
  resendVerificationEmail: (email: string) => Promise<void>;
  hasCompany: boolean;
}

export const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [loading, setLoading] = useState(true);
  const signUpInProgress = useRef(false);

  useEffect(() => {
    let mounted = true;
    const authSubscription = authService.onAuthStateChange((newUser) => {
      if (!mounted) return;
      if (signUpInProgress.current) {
        setUser(null);
        setLoading(false);
        return;
      }
      setUser((prev) => (authUsersEqual(prev, newUser) ? prev : newUser));
      setLoading(false);
    });

    return () => {
      mounted = false;
      authSubscription.data.subscription.unsubscribe();
    };
  }, []);

  const signUp = async (email: string, password: string, name: string): Promise<SignUpResult> => {
    signUpInProgress.current = true;
    setLoading(true);
    try {
      const result = await authService.signUp({ email, password, name });
      setUser(null);
      setLoading(false);
      return result;
    } catch (err) {
      setLoading(false);
      throw err;
    } finally {
      signUpInProgress.current = false;
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

  const resetPasswordForEmail = (email: string) => authService.resetPasswordForEmail(email);
  const updatePassword = (password: string) => authService.updatePassword(password);
  const resendVerificationEmail = (email: string) => authService.resendVerificationEmail(email);

  const hasCompany = !!user?.companyId;

  return (
    <AuthContext.Provider
      value={{
        user,
        loading,
        signUp,
        login,
        logout,
        refreshUser,
        resetPasswordForEmail,
        updatePassword,
        resendVerificationEmail,
        hasCompany,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

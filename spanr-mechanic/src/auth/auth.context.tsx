import { createContext, useEffect, useRef, useState } from 'react';
import { authService, authUsersEqual, type AuthUser } from './auth.service';

interface AuthContextType {
  user: AuthUser | null;
  loading: boolean;
  pendingPhone: string; // phone awaiting OTP verification
  sendOtp: (phone: string) => Promise<void>;
  verifyOtp: (phone: string, token: string) => Promise<void>;
  logout: () => Promise<void>;
  refreshUser: () => Promise<void>;
  resetPasswordForEmail: (email: string) => Promise<void>;
  updatePassword: (password: string) => Promise<void>;
  hasCompany: boolean;
}

export const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [loading, setLoading] = useState(true);
  const [pendingPhone, setPendingPhone] = useState('');
  const otpInProgress = useRef(false);

  useEffect(() => {
    let mounted = true;
    const authSubscription = authService.onAuthStateChange((newUser) => {
      if (!mounted) return;
      if (otpInProgress.current) return; // don't update during OTP flow
      setUser((prev) => (authUsersEqual(prev, newUser) ? prev : newUser));
      setLoading(false);
    });
    return () => {
      mounted = false;
      authSubscription.data.subscription.unsubscribe();
    };
  }, []);

  const sendOtp = async (phone: string) => {
    await authService.sendOtp(phone);
    setPendingPhone(phone);
  };

  const verifyOtp = async (phone: string, token: string) => {
    otpInProgress.current = true;
    setLoading(true);
    try {
      const currentUser = await authService.verifyOtp(phone, token);
      setUser((prev) => (authUsersEqual(prev, currentUser) ? prev : currentUser));
    } finally {
      otpInProgress.current = false;
      setLoading(false);
    }
  };

  const logout = async () => {
    await authService.logout();
    setUser(null);
    setPendingPhone('');
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

  const hasCompany = !!user?.companyId;

  return (
    <AuthContext.Provider
      value={{
        user,
        loading,
        pendingPhone,
        sendOtp,
        verifyOtp,
        logout,
        refreshUser,
        resetPasswordForEmail,
        updatePassword,
        hasCompany,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

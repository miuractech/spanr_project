import { createContext, useEffect, useState } from 'react';
import { authService, type AuthUser } from './auth.service';

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
    let authSubscription: ReturnType<typeof authService.onAuthStateChange> | null = null;

    // Initialize auth state
    const initAuth = async () => {
      try {
        // Check for existing session
        const session = await authService.getSession();
        
        if (!mounted) return;

        if (session) {
          // Get user details
          const currentUser = await authService.getCurrentUser();
          if (mounted) {
            setUser(currentUser);
          }
        } else {
          if (mounted) {
            setUser(null);
          }
        }
      } catch (error) {
        console.error('Failed to initialize auth:', error);
        if (mounted) {
          setUser(null);
        }
      } finally {
        if (mounted) {
          setLoading(false);

          authSubscription = authService.onAuthStateChange((newUser) => {
            if (mounted) {
              setUser(newUser);
              setLoading(false);
            }
          });
        }
      }
    };

    initAuth();

    return () => {
      mounted = false;
      if (authSubscription) {
        authSubscription.data.subscription.unsubscribe();
      }
    };
  }, []);

  const signUp = async (email: string, password: string, name: string) => {
    setLoading(true);
    try {
      await authService.signUp({ email, password, name });
      // loading cleared by onAuthStateChange
    } catch (err) {
      setLoading(false);
      throw err;
    }
  };

  const login = async (email: string, password: string) => {
    setLoading(true);
    try {
      await authService.login({ email, password });
      // loading cleared by onAuthStateChange
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
      setUser(currentUser);
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


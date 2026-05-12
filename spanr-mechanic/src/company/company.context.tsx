import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useState,
  type ReactNode,
} from 'react';
import { useAuth } from '../auth/auth.hook';
import { companyService, type CompanyProfile } from './company.service';

export type CompanyContextValue = {
  company: CompanyProfile | null;
  loading: boolean;
  error: string | null;
  refreshCompany: () => Promise<void>;
};

const CompanyContext = createContext<CompanyContextValue | null>(null);

export function CompanyProvider({ children }: { children: ReactNode }) {
  const { user } = useAuth();
  const [company, setCompany] = useState<CompanyProfile | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchCompany = useCallback(async (silent?: boolean) => {
    if (!user?.email) {
      setCompany(null);
      setLoading(false);
      return;
    }
    try {
      if (!silent) setLoading(true);
      const data = await companyService.getCompanyByStaffEmail(user.email);
      setCompany(data);
      setError(null);
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Failed to load company';
      setError(msg);
    } finally {
      if (!silent) setLoading(false);
    }
  }, [user?.email]);

  useEffect(() => {
    void fetchCompany(false);
  }, [user?.email, fetchCompany]);

  const refreshCompany = useCallback(() => fetchCompany(true), [fetchCompany]);

  return (
    <CompanyContext.Provider value={{ company, loading, error, refreshCompany }}>
      {children}
    </CompanyContext.Provider>
  );
}

export function useCompany(): CompanyContextValue {
  const ctx = useContext(CompanyContext);
  if (!ctx) {
    throw new Error('useCompany must be used within CompanyProvider');
  }
  return ctx;
}

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react';
import { useAuth } from '../auth/auth.hook';
import { companyService, toExistingDocuments, type CompanyProfile } from './company.service';
import { hasMandatoryKyc, operationsLocked as isOperationsLocked } from '../kyc/kyc.constants';

export type CompanyContextValue = {
  company: CompanyProfile | null;
  loading: boolean;
  error: string | null;
  refreshCompany: () => Promise<void>;
  hasMandatoryDocs: boolean;
  operationsLocked: boolean;
};

const CompanyContext = createContext<CompanyContextValue | null>(null);

export function CompanyProvider({ children }: { children: ReactNode }) {
  const { user } = useAuth();
  const [company, setCompany] = useState<CompanyProfile | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [hasMandatoryDocs, setHasMandatoryDocs] = useState(false);

  const fetchCompany = useCallback(async (silent?: boolean) => {
    if (!user?.email) {
      setCompany(null);
      setHasMandatoryDocs(false);
      setLoading(false);
      return;
    }
    try {
      if (!silent) setLoading(true);
      const data = await companyService.getCompanyByStaffEmail(user.email);
      setCompany(data);
      setError(null);
      if (!data) {
        setHasMandatoryDocs(false);
        return;
      }
      if (data.verification_status === 'verified') {
        setHasMandatoryDocs(true);
        return;
      }
      const docs = await companyService.getDocuments(data.id);
      setHasMandatoryDocs(hasMandatoryKyc(undefined, toExistingDocuments(docs)));
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

  const operationsLocked = useMemo(
    () => isOperationsLocked(company?.verification_status, hasMandatoryDocs),
    [company?.verification_status, hasMandatoryDocs]
  );

  return (
    <CompanyContext.Provider
      value={{ company, loading, error, refreshCompany, hasMandatoryDocs, operationsLocked }}
    >
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

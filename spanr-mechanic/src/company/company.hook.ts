import { useState, useEffect } from 'react';
import { companyService, type CompanyProfile } from './company.service';
import { useAuth } from '../auth/auth.hook';

export const useCompany = () => {
  const [company, setCompany] = useState<CompanyProfile | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const { user } = useAuth();

  const fetchCompany = async () => {
    if (!user?.email) {
      setLoading(false);
      return;
    }

    try {
      setLoading(true);
      const data = await companyService.getCompanyByStaffEmail(user.email);
      setCompany(data);
      setError(null);
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCompany();
  }, [user?.email]);

  const refreshCompany = () => {
    fetchCompany();
  };

  return {
    company,
    loading,
    error,
    refreshCompany,
  };
};


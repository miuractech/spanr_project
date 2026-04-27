import { useState, useEffect } from 'react';
import { staffService, type StaffWithAccess } from './staff.service';

export const useStaff = (companyId?: string) => {
  const [staff, setStaff] = useState<StaffWithAccess[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchStaff = async () => {
    if (!companyId) {
      setLoading(false);
      return;
    }

    try {
      setLoading(true);
      const data = await staffService.getStaffByCompany(companyId);
      setStaff(data);
      setError(null);
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchStaff();
  }, [companyId]);

  const refreshStaff = () => {
    fetchStaff();
  };

  return {
    staff,
    loading,
    error,
    refreshStaff,
  };
};


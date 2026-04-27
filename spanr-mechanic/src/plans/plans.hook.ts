import { useState, useEffect } from 'react';
import { plansService, type PlanDetails } from './plans.service';
import type { DbPlan } from '../types';

export const usePlans = (companyId?: string) => {
  const [plans, setPlans] = useState<DbPlan[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchPlans = async () => {
    if (!companyId) {
      setLoading(false);
      return;
    }

    try {
      setLoading(true);
      const data = await plansService.getPlansByCompany(companyId);
      setPlans(data);
      setError(null);
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchPlans();
  }, [companyId]);

  const refreshPlans = () => {
    fetchPlans();
  };

  return {
    plans,
    loading,
    error,
    refreshPlans,
  };
};

export const usePlanDetails = (planId?: string) => {
  const [planDetails, setPlanDetails] = useState<PlanDetails | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchPlanDetails = async () => {
    if (!planId) {
      setLoading(false);
      return;
    }

    try {
      setLoading(true);
      const data = await plansService.getPlanDetails(planId);
      setPlanDetails(data);
      setError(null);
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchPlanDetails();
  }, [planId]);

  return {
    planDetails,
    loading,
    error,
    refreshPlanDetails: fetchPlanDetails,
  };
};


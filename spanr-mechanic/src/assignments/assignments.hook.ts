import { useState, useEffect, useCallback } from 'react';
import { assignmentsService } from './assignments.service';
import type { OrderAssignment, StaffWorkload } from './assignments.types';

export const useOrderAssignment = (orderId?: string) => {
  const [assignment, setAssignment] = useState<OrderAssignment | null>(null);
  const [loading, setLoading] = useState(true);

  const refresh = useCallback(async () => {
    if (!orderId) return;
    setLoading(true);
    try {
      const data = await assignmentsService.getAssignmentByOrder(orderId);
      setAssignment(data);
    } finally {
      setLoading(false);
    }
  }, [orderId]);

  useEffect(() => { refresh(); }, [refresh]);

  return { assignment, loading, refresh };
};

export const useStaffWorkload = (companyId?: string) => {
  const [workload, setWorkload] = useState<StaffWorkload[]>([]);
  const [loading, setLoading] = useState(true);

  const refresh = useCallback(async () => {
    if (!companyId) return;
    setLoading(true);
    try {
      const data = await assignmentsService.getCompanyWorkload(companyId);
      setWorkload(data);
    } finally {
      setLoading(false);
    }
  }, [companyId]);

  useEffect(() => { refresh(); }, [refresh]);

  return { workload, loading, refresh };
};

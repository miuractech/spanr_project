import { useState, useEffect, useCallback } from 'react';
import { vehicleHistoryService } from './vehicle_history.service';
import type { ServiceRecordDetail, VehicleServiceRecord } from './vehicle_history.types';

export const useVehicleHistory = (companyId?: string, searchPlate?: string) => {
  const [records, setRecords] = useState<VehicleServiceRecord[]>([]);
  const [loading, setLoading] = useState(true);

  const refresh = useCallback(async () => {
    if (!companyId) return;
    setLoading(true);
    try {
      const data = searchPlate?.trim()
        ? await vehicleHistoryService.searchByPlate(companyId, searchPlate.trim())
        : await vehicleHistoryService.getHistoryByCompany(companyId);
      setRecords(data);
    } finally {
      setLoading(false);
    }
  }, [companyId, searchPlate]);

  useEffect(() => { refresh(); }, [refresh]);

  return { records, loading, refresh };
};

export const useServiceRecord = (recordId?: string) => {
  const [record, setRecord] = useState<ServiceRecordDetail | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!recordId) return;
    setLoading(true);
    vehicleHistoryService.getServiceRecord(recordId).then(setRecord).finally(() => setLoading(false));
  }, [recordId]);

  return { record, loading };
};

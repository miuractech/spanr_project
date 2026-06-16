import { Stack, Text, Loader, Alert } from '@mantine/core';
import { useVehicleHistory } from '../vehicle-history/vehicle_history.hook';
import { ServiceRecordCard } from './service_record_card';
import { vehicleHistoryService } from '../vehicle-history/vehicle_history.service';
import { useEffect, useState } from 'react';
import type { ServiceRecordDetail } from '../vehicle-history/vehicle_history.types';

interface VehicleHistoryTimelineProps {
  companyId: string;
  searchPlate?: string;
}

export const VehicleHistoryTimeline: React.FC<VehicleHistoryTimelineProps> = ({
  companyId,
  searchPlate,
}) => {
  const { records, loading } = useVehicleHistory(companyId, searchPlate);
  const [details, setDetails] = useState<ServiceRecordDetail[]>([]);
  const [loadingDetails, setLoadingDetails] = useState(false);

  useEffect(() => {
    if (records.length === 0) {
      setDetails([]);
      return;
    }
    setLoadingDetails(true);
    Promise.all(records.map((r) => vehicleHistoryService.getServiceRecord(r.id)))
      .then((results) => setDetails(results.filter(Boolean) as ServiceRecordDetail[]))
      .finally(() => setLoadingDetails(false));
  }, [records]);

  if (loading || loadingDetails) return <Loader />;
  if (details.length === 0) {
    return <Alert color="blue">No service history records found.</Alert>;
  }

  return (
    <Stack gap="md">
      <Text size="sm" c="dimmed">{details.length} service record(s)</Text>
      {details.map((record) => (
        <ServiceRecordCard key={record.id} record={record} />
      ))}
    </Stack>
  );
};

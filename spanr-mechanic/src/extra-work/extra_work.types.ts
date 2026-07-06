export type ExtraWorkStatus = 'pending' | 'approved' | 'rejected';

export interface ExtraWorkRequest {
  id: string;
  orderId: string;
  mechanicId: string | null;
  mechanicName?: string;
  description: string;
  photoUrl: string | null;
  estimatedCost: number;
  status: ExtraWorkStatus;
  rejectionReason: string | null;
  customerResponseAt: string | null;
  createdAt: string;
  updatedAt: string;
}

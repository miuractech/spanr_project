export interface JobSection {
  id: string;
  companyId: string;
  vehicleType: 'car' | 'bike';
  name: string;
  imageUrl: string | null;
  displayOrder: number;
  jobs?: JobCatalogItem[];
}

export interface JobCatalogItem {
  id: string;
  companyId: string;
  sectionId: string;
  name: string;
  thumbnailUrl: string | null;
  basePrice: number;
  displayOrder: number;
  isActive: boolean;
}

export type VehicleType = 'car' | 'bike';

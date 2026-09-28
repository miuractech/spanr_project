import type { DocumentType } from '../company/company.service';

export const MANDATORY_DOCUMENT_TYPES: DocumentType[] = [
  'aadhaar_front',
  'aadhaar_back',
  'personal_pan',
  'bank_passbook',
  'home_address_proof',
  'home_utility_bill',
  'shop_utility_bill',
];

export const MANDATORY_DOC_FILE_KEYS = [
  'aadhaarFront',
  'aadhaarBack',
  'personalPan',
  'bankPassbook',
  'homeAddressProof',
  'homeUtilityBill',
  'shopUtilityBill',
] as const;

export const DOCUMENT_TYPE_LABELS: Record<string, string> = {
  aadhaar_front: 'Aadhaar — Front',
  aadhaar_back: 'Aadhaar — Back',
  personal_pan: 'Personal PAN',
  bank_passbook: 'Bank passbook / cheque',
  home_address_proof: 'Home address proof',
  home_utility_bill: 'Home utility bill',
  shop_utility_bill: 'Shop utility bill',
  gst_certificate: 'GST certificate',
  firm_pan: 'Firm PAN',
  firm_registration: 'Firm registration',
  pan_card: 'PAN (legacy)',
  utility_bill: 'Utility bill (legacy)',
};

export function hasMandatoryKyc(
  files?: Partial<Record<(typeof MANDATORY_DOC_FILE_KEYS)[number], File | undefined>>,
  existing?: Partial<Record<(typeof MANDATORY_DOC_FILE_KEYS)[number], string | undefined>>
): boolean {
  return MANDATORY_DOC_FILE_KEYS.every((key) => Boolean(files?.[key] || existing?.[key]));
}

export function operationsLocked(
  status: 'pending' | 'verified' | 'rejected' | undefined,
  hasMandatoryDocs: boolean
): boolean {
  if (status === 'verified' || !status) return false;
  if (status === 'rejected') return true;
  return !hasMandatoryDocs;
}

export const KYC_ALLOWED_PATHS = ['/dashboard', '/company-profile', '/profile'];

export function isKycAllowedPath(pathname: string): boolean {
  return KYC_ALLOWED_PATHS.some(
    (path) => pathname === path || pathname.startsWith(`${path}/`)
  );
}

export function documentLabel(type: string): string {
  return DOCUMENT_TYPE_LABELS[type] ?? type.replace(/_/g, ' ');
}

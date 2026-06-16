const STAFF_AUTH_EMAIL_DOMAIN = 'spanr.staff';

export function normalizePhone(phone: string): string {
  const digits = phone.replace(/\D/g, '');
  if (digits.length === 10) return `91${digits}`;
  if (digits.length === 12 && digits.startsWith('91')) return digits;
  if (digits.length === 11 && digits.startsWith('0')) return `91${digits.slice(1)}`;
  return digits;
}

export function phoneToAuthEmail(phone: string): string {
  return `${normalizePhone(phone)}@${STAFF_AUTH_EMAIL_DOMAIN}`;
}

export function isStaffAuthEmail(email: string): boolean {
  return email.endsWith(`@${STAFF_AUTH_EMAIL_DOMAIN}`);
}

export function formatPhoneDisplay(phone: string): string {
  const n = normalizePhone(phone);
  if (n.length === 12 && n.startsWith('91')) {
    return `+91 ${n.slice(2, 7)} ${n.slice(7)}`;
  }
  return phone;
}

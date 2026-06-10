export type PasswordStrength = 'empty' | 'weak' | 'fair' | 'good' | 'strong';

export interface PasswordStrengthResult {
  strength: PasswordStrength;
  score: number;
  label: string;
  color: string;
  checks: {
    minLength: boolean;
    hasUppercase: boolean;
    hasLowercase: boolean;
    hasNumber: boolean;
    hasSpecial: boolean;
  };
}

export function getPasswordStrength(password: string): PasswordStrengthResult {
  const checks = {
    minLength: password.length >= 8,
    hasUppercase: /[A-Z]/.test(password),
    hasLowercase: /[a-z]/.test(password),
    hasNumber: /\d/.test(password),
    hasSpecial: /[^A-Za-z0-9]/.test(password),
  };

  const score = Object.values(checks).filter(Boolean).length;

  if (!password) {
    return { strength: 'empty', score: 0, label: '', color: 'gray', checks };
  }
  if (score <= 2) {
    return { strength: 'weak', score, label: 'Weak', color: 'red', checks };
  }
  if (score === 3) {
    return { strength: 'fair', score, label: 'Fair', color: 'orange', checks };
  }
  if (score === 4) {
    return { strength: 'good', score, label: 'Good', color: 'yellow', checks };
  }
  return { strength: 'strong', score, label: 'Strong', color: 'green', checks };
}

export function isPasswordStrongEnough(password: string): boolean {
  const { strength } = getPasswordStrength(password);
  return strength === 'good' || strength === 'strong';
}

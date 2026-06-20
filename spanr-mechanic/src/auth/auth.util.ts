export const appOrigin = () => import.meta.env.VITE_APP_URL || window.location.origin;
export const authCallbackUrl = () => `${appOrigin()}/auth/callback`;
export const resetPasswordUrl = () => `${appOrigin()}/reset-password`;
export function getAuthErrorMessage(error: unknown, fallback: string): string {
  if (error && typeof error === 'object' && 'message' in error) {
    const message = String((error as { message: string }).message);
    if (message.toLowerCase().includes('email not confirmed')) {
      return 'Please verify your email before signing in.';
    }
    return message;
  }
  return fallback;
}

export function isEmailVerified(user: { email_confirmed_at?: string | null } | null | undefined): boolean {
  return !!user?.email_confirmed_at;
}

export function isEmailNotConfirmedError(error: unknown): boolean {
  if (error && typeof error === 'object' && 'message' in error) {
    return String((error as { message: string }).message)
      .toLowerCase()
      .includes('email not confirmed');
  }
  return false;
}

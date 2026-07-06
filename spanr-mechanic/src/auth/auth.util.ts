export const appOrigin = () => import.meta.env.VITE_APP_URL || window.location.origin;
export const resetPasswordUrl = () => `${appOrigin()}/reset-password`;

export function getAuthErrorMessage(error: unknown, fallback: string): string {
  if (error && typeof error === 'object' && 'message' in error) {
    return String((error as { message: string }).message) || fallback;
  }
  return fallback;
}

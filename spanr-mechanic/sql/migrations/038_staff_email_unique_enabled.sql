-- Prevent duplicate enabled staff rows per email (failed onboarding retries)
CREATE UNIQUE INDEX IF NOT EXISTS idx_staff_email_enabled_unique
  ON staff (lower(email))
  WHERE enabled = true;

-- Staff phone login + forced password change flag

ALTER TABLE staff ADD COLUMN IF NOT EXISTS phone TEXT;

ALTER TABLE staff_profiles
  ADD COLUMN IF NOT EXISTS must_change_password BOOLEAN NOT NULL DEFAULT true;

CREATE UNIQUE INDEX IF NOT EXISTS uq_staff_company_phone
  ON staff(company_id, phone)
  WHERE phone IS NOT NULL;

CREATE OR REPLACE FUNCTION complete_staff_password_change()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE staff_profiles
  SET must_change_password = false
  WHERE staff_id = auth_staff_id();
END;
$$;

GRANT EXECUTE ON FUNCTION complete_staff_password_change() TO authenticated;

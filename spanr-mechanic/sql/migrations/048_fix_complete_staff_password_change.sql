-- Fix silent no-op in complete_staff_password_change():
-- if auth_staff_id() can't resolve a matching staff row (e.g. staff.auth_user_id
-- was never linked during provisioning), the UPDATE previously affected 0 rows
-- and returned success anyway, leaving must_change_password stuck at true and
-- the mechanic app looping back to /change-password forever with no error shown.
-- Now it raises so the app can surface a real error instead of a silent bounce.

CREATE OR REPLACE FUNCTION complete_staff_password_change()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_staff_id UUID;
BEGIN
  v_staff_id := auth_staff_id();

  IF v_staff_id IS NULL THEN
    RAISE EXCEPTION 'Could not resolve staff record for the current login. Please contact support.'
      USING ERRCODE = 'P0001';
  END IF;

  UPDATE staff_profiles
  SET must_change_password = false
  WHERE staff_id = v_staff_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Failed to update password status for this staff record. Please contact support.'
      USING ERRCODE = 'P0001';
  END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION complete_staff_password_change() TO authenticated;

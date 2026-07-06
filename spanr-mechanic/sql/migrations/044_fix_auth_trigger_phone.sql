-- =====================================================
-- Fix handle_new_user trigger for phone OTP owners
-- The trigger inserts into public.users (customer table).
-- Owner phone-OTP accounts have email = NULL or end with
-- @spanr.owner / @spanr.staff — they must be skipped.
-- =====================================================

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Skip staff and owner accounts; they live in the staff table, not public.users.
  IF NEW.email IS NULL
     OR NEW.email LIKE '%@spanr.owner'
     OR NEW.email LIKE '%@spanr.staff' THEN
    RETURN NEW;
  END IF;

  INSERT INTO public.users (id, email, name, phone)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', NEW.email),
    COALESCE(NEW.raw_user_meta_data->>'phone', '')
  )
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
END;
$$;

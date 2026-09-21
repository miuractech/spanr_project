-- Fix Super Admin spinner hang:
-- 1. is_super_admin() must not recurse through admin_users RLS
-- 2. Clients can only read their own admin_users row (no policy that calls is_super_admin)

CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.am_i_super_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN public.is_super_admin();
END;
$$;

GRANT EXECUTE ON FUNCTION public.is_super_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION public.am_i_super_admin() TO authenticated;

DROP POLICY IF EXISTS "Admins can view admin_users" ON admin_users;
DROP POLICY IF EXISTS "Users can read own admin_users row" ON admin_users;
CREATE POLICY "Users can read own admin_users row"
  ON admin_users FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE OR REPLACE FUNCTION public.has_any_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (SELECT 1 FROM public.admin_users);
$$;

GRANT EXECUTE ON FUNCTION public.has_any_admin() TO authenticated;

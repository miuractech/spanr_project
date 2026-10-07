-- 056: Security hardening (audit of 2026-10-05)
--
-- Closes the following, all reachable with the public anon key plus any login:
--   * Any signed-in user could INSERT a staff row into any shop and become its
--     admin (orders, customer PII, Aadhaar/PAN/bank KYC files, prices).
--   * Every mechanic-app login had full owner rights. Staff now carry a role
--     and user_company_id() only resolves for owners/admins.
--   * Customers could INSERT payments as 'paid', change payments.amount /
--     razorpay_order_id, and edit any column of their orders.
--   * Shops could mark themselves / their KYC documents as verified.
--   * KYC storage was readable and deletable by every signed-in user.
--   * Several leftover WITH CHECK (true) / USING (true) policies.
--   * complete_job(), assign_order_to_staff() and admin_add_admin() authz gaps.
--
-- Column guards below use `current_user IN ('authenticated','anon')` to detect
-- direct client writes. SECURITY DEFINER functions (RPCs, triggers) run as the
-- function owner and the service role runs as service_role, so trusted
-- server-side paths are unaffected.
--
-- Apply after 055_order_additional_payments.sql.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'payments' AND column_name = 'kind'
  ) THEN
    RAISE EXCEPTION 'Apply 055_order_additional_payments.sql before 056_security_hardening.sql';
  END IF;
END $$;

-- ===========================================================================
-- 1. Staff roles and shop ownership
-- ===========================================================================

ALTER TABLE staff ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'mechanic';
ALTER TABLE staff DROP CONSTRAINT IF EXISTS staff_role_check;
ALTER TABLE staff ADD CONSTRAINT staff_role_check CHECK (role IN ('owner', 'admin', 'mechanic'));

-- Mechanic-app logins are <phone>@spanr.staff. Every other staff row is a
-- dashboard login: the earliest per shop is the owner, the rest stay admins
-- (they already had full rights before this migration).
WITH ranked AS (
  SELECT id, row_number() OVER (PARTITION BY company_id ORDER BY created_at, id) AS rn
  FROM staff
  WHERE email NOT LIKE '%@spanr.staff'
)
UPDATE staff s
SET role = CASE WHEN r.rn = 1 THEN 'owner' ELSE 'admin' END
FROM ranked r
WHERE s.id = r.id
  AND s.role = 'mechanic';

ALTER TABLE mechanic_companies ADD COLUMN IF NOT EXISTS created_by UUID DEFAULT auth.uid();

-- Link legacy email owners to their auth account so identity no longer
-- depends on matching the JWT email.
UPDATE staff s
SET auth_user_id = u.id
FROM auth.users u
WHERE s.auth_user_id IS NULL
  AND s.email NOT LIKE '%@spanr.staff'
  AND s.email NOT LIKE '%@spanr.owner'
  AND u.email IS NOT NULL
  AND lower(u.email) = lower(s.email)
  AND u.email_confirmed_at IS NOT NULL;

-- ===========================================================================
-- 2. Identity helpers
-- ===========================================================================

-- The caller's staff row. Matched by auth_user_id; the email fallback is only
-- for unlinked legacy rows, never for the synthetic @spanr.* domains (anyone
-- could register those addresses), and only for a confirmed email.
CREATE OR REPLACE FUNCTION public.auth_staff_id()
RETURNS UUID
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT s.id
  FROM staff s
  WHERE s.enabled = true
    AND (
      s.auth_user_id = auth.uid()
      OR (
        s.auth_user_id IS NULL
        AND s.email = NULLIF(auth.jwt()->>'email', '')
        AND s.email NOT LIKE '%@spanr.staff'
        AND s.email NOT LIKE '%@spanr.owner'
        AND EXISTS (
          SELECT 1 FROM auth.users u
          WHERE u.id = auth.uid() AND u.email_confirmed_at IS NOT NULL
        )
      )
    )
  ORDER BY CASE WHEN s.auth_user_id = auth.uid() THEN 0 ELSE 1 END, s.created_at
  LIMIT 1
$$;

-- Shop of any staff member (mechanics included). Use for read-only scoping.
CREATE OR REPLACE FUNCTION public.auth_staff_company_id()
RETURNS UUID
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT company_id FROM staff WHERE id = public.auth_staff_id()
$$;

-- Shop the caller can MANAGE. Every existing "company staff can ..." policy
-- uses this, so they all become owner/admin-only.
CREATE OR REPLACE FUNCTION public.user_company_id()
RETURNS UUID
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT company_id
  FROM staff
  WHERE id = public.auth_staff_id()
    AND role IN ('owner', 'admin')
$$;

-- True only while the caller's freshly created shop has no staff yet, i.e. the
-- single onboarding insert of the owner row.
CREATE OR REPLACE FUNCTION public.company_bootstrap_allowed(p_company_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT auth.uid() IS NOT NULL
    AND EXISTS (
      SELECT 1 FROM mechanic_companies c
      WHERE c.id = p_company_id AND c.created_by = auth.uid()
    )
    AND NOT EXISTS (SELECT 1 FROM staff s WHERE s.company_id = p_company_id)
$$;

CREATE OR REPLACE FUNCTION public.try_uuid(p_value TEXT)
RETURNS UUID
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  RETURN p_value::uuid;
EXCEPTION WHEN others THEN
  RETURN NULL;
END;
$$;

CREATE OR REPLACE FUNCTION public.user_on_company_order(p_user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM orders o
    WHERE o.user_id = p_user_id
      AND o.company_id = public.user_company_id()
  );
$$;

CREATE OR REPLACE FUNCTION public.user_on_assigned_order(p_user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM orders o
    JOIN order_assignments oa ON oa.order_id = o.id
    WHERE o.user_id = p_user_id
      AND oa.staff_id = public.auth_staff_id()
      AND oa.status IN ('active', 'completed')
  );
$$;

-- Server-side booking price, same formula as the app's CartItem.total.
CREATE OR REPLACE FUNCTION public.booking_amount_for_order(p_order_id UUID)
RETURNS NUMERIC
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT ROUND(p.base_price * (1 + COALESCE(p.tax, 0) / 100), 2)
  FROM orders o
  JOIN plans p ON p.id = o.plan_id
  WHERE o.id = p_order_id
    AND o.user_id = auth.uid()
$$;

CREATE OR REPLACE FUNCTION public.order_booking_is_valid(
  p_company_id UUID,
  p_plan_id UUID,
  p_vehicle_id UUID
)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (SELECT 1 FROM plans p WHERE p.id = p_plan_id AND p.company_id = p_company_id)
     AND public.company_is_verified(p_company_id)
     AND EXISTS (SELECT 1 FROM vehicles v WHERE v.id = p_vehicle_id AND v.user_id = auth.uid())
$$;

-- ===========================================================================
-- 3. staff
-- ===========================================================================

DROP POLICY IF EXISTS "Users can create staff records" ON staff;
DROP POLICY IF EXISTS "Owners can add staff" ON staff;
CREATE POLICY "Owners can add staff"
  ON staff FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id = user_company_id()
    OR company_bootstrap_allowed(company_id)
  );

DROP POLICY IF EXISTS "Users can view their own staff record" ON staff;
CREATE POLICY "Users can view their own staff record"
  ON staff FOR SELECT
  TO authenticated
  USING (id = auth_staff_id() OR auth_user_id = auth.uid());

DROP POLICY IF EXISTS "Staff can update company staff" ON staff;
CREATE POLICY "Staff can update company staff"
  ON staff FOR UPDATE
  TO authenticated
  USING (company_id = user_company_id())
  WITH CHECK (company_id = user_company_id());

DROP POLICY IF EXISTS "Staff can delete company staff" ON staff;
CREATE POLICY "Staff can delete company staff"
  ON staff FOR DELETE
  TO authenticated
  USING (company_id = user_company_id() AND role <> 'owner');

CREATE OR REPLACE FUNCTION public.staff_guard()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  IF current_user NOT IN ('authenticated', 'anon') THEN
    RETURN NEW;
  END IF;

  IF TG_OP = 'INSERT' THEN
    IF public.company_bootstrap_allowed(NEW.company_id) THEN
      NEW.role := 'owner';
      NEW.auth_user_id := auth.uid();
      NEW.enabled := true;
    ELSE
      -- Logins are linked only by provision-staff-auth (service role).
      NEW.role := 'mechanic';
      NEW.auth_user_id := NULL;
    END IF;
    RETURN NEW;
  END IF;

  IF OLD.role = 'owner' AND OLD.id IS DISTINCT FROM public.auth_staff_id() THEN
    RAISE EXCEPTION 'Only the shop owner can change the owner account' USING ERRCODE = '42501';
  END IF;

  NEW.role := OLD.role;
  NEW.auth_user_id := OLD.auth_user_id;
  NEW.company_id := OLD.company_id;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_staff_guard ON staff;
CREATE TRIGGER trg_staff_guard
  BEFORE INSERT OR UPDATE ON staff
  FOR EACH ROW
  EXECUTE FUNCTION public.staff_guard();

CREATE OR REPLACE FUNCTION public.staff_profiles_guard()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  IF current_user NOT IN ('authenticated', 'anon') THEN
    RETURN NEW;
  END IF;

  IF TG_OP = 'INSERT' THEN
    NEW.must_change_password := true;
  ELSE
    NEW.staff_id := OLD.staff_id;
    -- Cleared only through complete_staff_password_change().
    IF OLD.must_change_password AND NOT NEW.must_change_password THEN
      NEW.must_change_password := true;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_staff_profiles_guard ON staff_profiles;
CREATE TRIGGER trg_staff_profiles_guard
  BEFORE INSERT OR UPDATE ON staff_profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.staff_profiles_guard();

DROP POLICY IF EXISTS "Authenticated users can manage staff access" ON staff_access;

DROP POLICY IF EXISTS "Staff can mark own attendance" ON staff_attendance;
CREATE POLICY "Staff can mark own attendance"
  ON staff_attendance FOR INSERT
  TO authenticated
  WITH CHECK (staff_id = auth_staff_id() AND company_id = auth_staff_company_id());

-- ===========================================================================
-- 4. mechanic_companies: shops cannot verify themselves
-- ===========================================================================

DROP POLICY IF EXISTS "Authenticated users can create mechanic companies" ON mechanic_companies;
CREATE POLICY "Authenticated users can create mechanic companies"
  ON mechanic_companies FOR INSERT
  TO authenticated
  WITH CHECK (created_by = auth.uid());

-- Onboarding reads the new row back before the owner staff row exists.
DROP POLICY IF EXISTS "Creators can view their company" ON mechanic_companies;
CREATE POLICY "Creators can view their company"
  ON mechanic_companies FOR SELECT
  TO authenticated
  USING (created_by = auth.uid());

DROP POLICY IF EXISTS "Staff can view own company" ON mechanic_companies;
CREATE POLICY "Staff can view own company"
  ON mechanic_companies FOR SELECT
  TO authenticated
  USING (id = auth_staff_company_id());

CREATE OR REPLACE FUNCTION public.mechanic_companies_guard()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  IF current_user NOT IN ('authenticated', 'anon') THEN
    RETURN NEW;
  END IF;

  IF TG_OP = 'INSERT' THEN
    NEW.verification_status := 'pending';
    NEW.verification_notes := NULL;
    NEW.verified_at := NULL;
    NEW.verified_by := NULL;
    NEW.created_by := auth.uid();
  ELSE
    -- Changed only by admin_set_company_verification / owner_submit_kyc_for_review.
    NEW.id := OLD.id;
    NEW.verification_status := OLD.verification_status;
    NEW.verification_notes := OLD.verification_notes;
    NEW.verified_at := OLD.verified_at;
    NEW.verified_by := OLD.verified_by;
    NEW.created_by := OLD.created_by;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_mechanic_companies_guard ON mechanic_companies;
CREATE TRIGGER trg_mechanic_companies_guard
  BEFORE INSERT OR UPDATE ON mechanic_companies
  FOR EACH ROW
  EXECUTE FUNCTION public.mechanic_companies_guard();

DROP POLICY IF EXISTS "Authenticated users can insert company ratings" ON company_ratings;
DROP POLICY IF EXISTS "Authenticated users can update company ratings" ON company_ratings;
DROP POLICY IF EXISTS "Authenticated users can insert certifications" ON company_certifications;
DROP POLICY IF EXISTS "Authenticated users can update certifications" ON company_certifications;
DROP POLICY IF EXISTS "Authenticated users can delete certifications" ON company_certifications;
DROP POLICY IF EXISTS "Authenticated users can insert specializations" ON company_specializations;
DROP POLICY IF EXISTS "Authenticated users can update specializations" ON company_specializations;
DROP POLICY IF EXISTS "Authenticated users can delete specializations" ON company_specializations;

-- Mechanics still need their own shop's catalogue in the app (embedded in the
-- job query), even before the shop is verified.
DROP POLICY IF EXISTS "Staff can view own shop plans" ON plans;
CREATE POLICY "Staff can view own shop plans"
  ON plans FOR SELECT
  TO authenticated
  USING (company_id = auth_staff_company_id());

DROP POLICY IF EXISTS "Staff can view own shop services" ON services;
CREATE POLICY "Staff can view own shop services"
  ON services FOR SELECT
  TO authenticated
  USING (company_id = auth_staff_company_id());

-- ===========================================================================
-- 5. company_documents: no self-approval, no foreign paths
-- ===========================================================================

CREATE OR REPLACE FUNCTION public.company_documents_guard()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  IF current_user NOT IN ('authenticated', 'anon') THEN
    RETURN NEW;
  END IF;

  IF TG_OP = 'UPDATE' THEN
    NEW.company_id := OLD.company_id;
  END IF;

  -- Must be an object path inside this shop's folder. A URL here would be
  -- rendered in the Super Admin desk, and another shop's path would be signed
  -- with admin rights.
  IF NEW.file_url IS NULL
     OR NEW.file_url NOT LIKE NEW.company_id::text || '/%'
     OR NEW.file_url LIKE '%..%'
     OR NEW.file_url LIKE '%://%' THEN
    RAISE EXCEPTION 'Invalid document path' USING ERRCODE = '22023';
  END IF;

  IF TG_OP = 'INSERT' THEN
    NEW.verified := 'pending';
    NEW.rejection_reason := NULL;
  ELSIF NEW.file_url IS NOT DISTINCT FROM OLD.file_url
        AND NEW.file_name IS NOT DISTINCT FROM OLD.file_name THEN
    -- Review outcome is set only by admin_set_document_verification().
    NEW.verified := OLD.verified;
    NEW.rejection_reason := OLD.rejection_reason;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_company_documents_guard ON company_documents;
CREATE TRIGGER trg_company_documents_guard
  BEFORE INSERT OR UPDATE ON company_documents
  FOR EACH ROW
  EXECUTE FUNCTION public.company_documents_guard();

-- ===========================================================================
-- 6. orders
-- ===========================================================================

CREATE OR REPLACE FUNCTION public.orders_guard()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  IF current_user NOT IN ('authenticated', 'anon') THEN
    RETURN NEW;
  END IF;

  IF TG_OP = 'INSERT' THEN
    IF NOT public.order_booking_is_valid(NEW.company_id, NEW.plan_id, NEW.vehicle_id) THEN
      RAISE EXCEPTION 'This plan, shop or vehicle is not available for booking' USING ERRCODE = '42501';
    END IF;
    NEW.status := 'created';
    RETURN NEW;
  END IF;

  NEW.id := OLD.id;
  NEW.user_id := OLD.user_id;
  NEW.company_id := OLD.company_id;
  NEW.plan_id := OLD.plan_id;
  NEW.vehicle_id := OLD.vehicle_id;
  NEW.order_date := OLD.order_date;
  NEW.created_at := OLD.created_at;

  IF NEW.status IS NOT DISTINCT FROM OLD.status THEN
    RETURN NEW;
  END IF;

  -- Shop owners/admins run their own order lifecycle.
  IF OLD.company_id = public.user_company_id() THEN
    RETURN NEW;
  END IF;

  -- Assigned mechanic: working states only. Completion goes through complete_job().
  IF public.staff_assigned_to_order(OLD.id, ARRAY['active']::assignment_status[]) THEN
    IF NEW.status::text IN ('in_progress', 'waiting_for_parts', 'on_hold', 'ready_for_delivery') THEN
      RETURN NEW;
    END IF;
    RAISE EXCEPTION 'Mechanics cannot set an order to %', NEW.status USING ERRCODE = '42501';
  END IF;

  IF OLD.user_id = auth.uid() THEN
    IF NEW.status::text = 'cancelled'
       AND OLD.status::text IN ('created', 'accepted', 'assigned') THEN
      RETURN NEW;
    END IF;
    -- Resuming after extra-work approval is done by the database (057).
    RAISE EXCEPTION 'This order can no longer be changed from the app' USING ERRCODE = '42501';
  END IF;

  RAISE EXCEPTION 'Not allowed to change this order' USING ERRCODE = '42501';
END;
$$;

DROP TRIGGER IF EXISTS trg_orders_guard ON orders;
CREATE TRIGGER trg_orders_guard
  BEFORE INSERT OR UPDATE ON orders
  FOR EACH ROW
  EXECUTE FUNCTION public.orders_guard();

-- History rows are written by the trigger; run it as owner so clients do not
-- need (and cannot abuse) a blanket INSERT policy.
CREATE OR REPLACE FUNCTION public.create_order_history_entry()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF (TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND OLD.status IS DISTINCT FROM NEW.status)) THEN
    INSERT INTO order_history (order_id, status, notes)
    VALUES (NEW.id, NEW.status,
      CASE
        WHEN TG_OP = 'INSERT' THEN 'Order created'
        ELSE 'Status changed from ' || OLD.status::text || ' to ' || NEW.status::text
      END
    );
  END IF;
  RETURN NEW;
END;
$$;

DROP POLICY IF EXISTS "System can insert order history" ON order_history;
DROP POLICY IF EXISTS "Shop staff can add order history" ON order_history;
CREATE POLICY "Shop staff can add order history"
  ON order_history FOR INSERT
  TO authenticated
  WITH CHECK (
    order_belongs_to_user_company(order_id)
    OR staff_assigned_to_order(order_id, ARRAY['active']::assignment_status[])
  );

DROP POLICY IF EXISTS "Assigned staff can view order history" ON order_history;
CREATE POLICY "Assigned staff can view order history"
  ON order_history FOR SELECT
  TO authenticated
  USING (staff_assigned_to_order(order_id, ARRAY['active', 'completed']::assignment_status[]));

DROP POLICY IF EXISTS "Users can insert before images" ON order_before_images;
DROP POLICY IF EXISTS "Authenticated users can insert before images" ON order_before_images;
DROP POLICY IF EXISTS "Order parties can add before images" ON order_before_images;
CREATE POLICY "Order parties can add before images"
  ON order_before_images FOR INSERT
  TO authenticated
  WITH CHECK (
    order_belongs_to_user(order_id)
    OR order_belongs_to_user_company(order_id)
    OR staff_assigned_to_order(order_id, ARRAY['active']::assignment_status[])
  );

DROP POLICY IF EXISTS "Assigned staff can view order before images" ON order_before_images;
CREATE POLICY "Assigned staff can view order before images"
  ON order_before_images FOR SELECT
  TO authenticated
  USING (staff_assigned_to_order(order_id, ARRAY['active', 'completed']::assignment_status[]));

DROP POLICY IF EXISTS "Assigned staff can view order after images" ON order_after_images;
CREATE POLICY "Assigned staff can view order after images"
  ON order_after_images FOR SELECT
  TO authenticated
  USING (staff_assigned_to_order(order_id, ARRAY['active', 'completed']::assignment_status[]));

DROP POLICY IF EXISTS "Assigned staff can add order after images" ON order_after_images;
CREATE POLICY "Assigned staff can add order after images"
  ON order_after_images FOR INSERT
  TO authenticated
  WITH CHECK (staff_assigned_to_order(order_id, ARRAY['active']::assignment_status[]));

DROP POLICY IF EXISTS "Assigned staff can view order selected jobs" ON order_selected_jobs;
CREATE POLICY "Assigned staff can view order selected jobs"
  ON order_selected_jobs FOR SELECT
  TO authenticated
  USING (staff_assigned_to_order(order_id, ARRAY['active', 'completed']::assignment_status[]));

-- 033's versions let a mechanic INSERT an assignment for themselves on any
-- shop's order (staff_id = auth_staff_id()), then read and edit that order.
-- 045's company-scoped policies remain for owners/admins.
DROP POLICY IF EXISTS "Company staff can manage assignments" ON order_assignments;
DROP POLICY IF EXISTS "Company staff can view assignments" ON order_assignments;
DROP POLICY IF EXISTS "Staff can view own assignments" ON order_assignments;
CREATE POLICY "Staff can view own assignments"
  ON order_assignments FOR SELECT
  TO authenticated
  USING (staff_id = auth_staff_id());

-- Customers: scope to their own customers / assigned jobs instead of the old
-- raw-email subquery, which let every mechanic read every customer of the shop.
DROP POLICY IF EXISTS "Staff can view users with orders in their company" ON users;
DROP POLICY IF EXISTS "Shop admins can view their customers" ON users;
CREATE POLICY "Shop admins can view their customers"
  ON users FOR SELECT
  TO authenticated
  USING (user_on_company_order(id));

DROP POLICY IF EXISTS "Assigned staff can view their customers" ON users;
CREATE POLICY "Assigned staff can view their customers"
  ON users FOR SELECT
  TO authenticated
  USING (user_on_assigned_order(id));

-- ===========================================================================
-- 7. payments: amount and status are server-side facts
-- ===========================================================================

DROP POLICY IF EXISTS "Users can insert payments" ON payments;
CREATE POLICY "Users can insert payments"
  ON payments FOR INSERT
  TO authenticated
  WITH CHECK (order_belongs_to_user(order_id));

CREATE OR REPLACE FUNCTION public.payments_guard()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  IF current_user NOT IN ('authenticated', 'anon') THEN
    RETURN NEW;
  END IF;

  IF TG_OP = 'INSERT' THEN
    -- Additional-charge rows are created only by refresh_order_additional_payment().
    NEW.kind := 'booking';
    NEW.status := 'unpaid';
    NEW.amount := public.booking_amount_for_order(NEW.order_id);
    IF NEW.amount IS NULL OR NEW.amount <= 0 THEN
      RAISE EXCEPTION 'Could not price this order' USING ERRCODE = '22023';
    END IF;
    NEW.paid_at := NULL;
    NEW.transaction_id := NULL;
    NEW.failure_reason := NULL;
    -- Attached by the create-razorpay-order edge function.
    NEW.razorpay_order_id := NULL;
    NEW.razorpay_payment_id := NULL;
    NEW.razorpay_signature := NULL;
    RETURN NEW;
  END IF;

  NEW.id := OLD.id;
  NEW.order_id := OLD.order_id;
  NEW.kind := OLD.kind;
  NEW.amount := OLD.amount;
  NEW.razorpay_order_id := OLD.razorpay_order_id;
  NEW.paid_at := OLD.paid_at;
  NEW.transaction_id := OLD.transaction_id;
  NEW.failure_reason := OLD.failure_reason;
  NEW.created_at := OLD.created_at;

  -- The app may only report "checkout finished, awaiting webhook".
  IF NEW.status IS DISTINCT FROM OLD.status
     AND NOT (OLD.status = 'unpaid' AND NEW.status = 'processing') THEN
    RAISE EXCEPTION 'Payment status is set by the payment gateway' USING ERRCODE = '42501';
  END IF;
  IF OLD.status <> 'unpaid' THEN
    NEW.razorpay_payment_id := OLD.razorpay_payment_id;
    NEW.razorpay_signature := OLD.razorpay_signature;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_payments_guard ON payments;
CREATE TRIGGER trg_payments_guard
  BEFORE INSERT OR UPDATE ON payments
  FOR EACH ROW
  EXECUTE FUNCTION public.payments_guard();

-- The webhook resolves payments by razorpay_order_id; a duplicate would make
-- it fail to settle the real payment.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM payments
    WHERE razorpay_order_id IS NOT NULL
    GROUP BY razorpay_order_id
    HAVING count(*) > 1
  ) THEN
    RAISE WARNING 'payments.razorpay_order_id has duplicates; uq_payments_razorpay_order_id not created. Resolve them and re-run this block.';
  ELSE
    CREATE UNIQUE INDEX IF NOT EXISTS uq_payments_razorpay_order_id
      ON payments (razorpay_order_id)
      WHERE razorpay_order_id IS NOT NULL;
  END IF;
END $$;

-- Additional charges (055). Never resize or delete a row once checkout has
-- started: Razorpay will capture the amount it was created with. Any
-- difference is billed in a fresh row after that one settles.
CREATE OR REPLACE FUNCTION public.refresh_order_additional_payment(p_order_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_parts NUMERIC(10, 2);
  v_extra NUMERIC(10, 2);
  v_due NUMERIC(10, 2);
  v_paid_extra NUMERIC(10, 2);
  v_remaining NUMERIC(10, 2);
  v_open_id UUID;
  v_open_locked BOOLEAN;
BEGIN
  SELECT COALESCE(SUM(cost), 0) INTO v_parts
  FROM parts_replaced
  WHERE order_id = p_order_id;

  SELECT COALESCE(SUM(estimated_cost), 0) INTO v_extra
  FROM extra_work_requests
  WHERE order_id = p_order_id
    AND status = 'approved';

  v_due := COALESCE(v_parts, 0) + COALESCE(v_extra, 0);

  SELECT COALESCE(SUM(amount), 0) INTO v_paid_extra
  FROM payments
  WHERE order_id = p_order_id
    AND kind = 'additional'
    AND status = 'paid';

  v_remaining := ROUND(v_due - v_paid_extra, 2);

  SELECT id, (status = 'processing' OR razorpay_order_id IS NOT NULL)
  INTO v_open_id, v_open_locked
  FROM payments
  WHERE order_id = p_order_id
    AND kind = 'additional'
    AND status IN ('unpaid', 'processing')
  LIMIT 1;

  IF v_open_locked THEN
    RETURN;
  END IF;

  IF v_remaining <= 0 THEN
    IF v_open_id IS NOT NULL THEN
      DELETE FROM payments WHERE id = v_open_id;
    END IF;
    RETURN;
  END IF;

  IF v_open_id IS NOT NULL THEN
    UPDATE payments
    SET amount = v_remaining,
        updated_at = NOW()
    WHERE id = v_open_id;
  ELSE
    INSERT INTO payments (order_id, method, status, amount, kind)
    VALUES (p_order_id, 'upi', 'unpaid', v_remaining, 'additional');
  END IF;
END;
$$;

-- Internal only (called from triggers). It took any order id from any caller.
REVOKE EXECUTE ON FUNCTION public.refresh_order_additional_payment(UUID) FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.trg_payment_settled_refresh_additional()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.kind = 'additional'
     AND NEW.status IS DISTINCT FROM OLD.status
     AND NEW.status IN ('paid', 'failed') THEN
    PERFORM public.refresh_order_additional_payment(NEW.order_id);
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_payments_refresh_additional ON payments;
CREATE TRIGGER trg_payments_refresh_additional
  AFTER UPDATE OF status ON payments
  FOR EACH ROW
  EXECUTE FUNCTION public.trg_payment_settled_refresh_additional();

-- ===========================================================================
-- 8. Extra work and parts feed the customer's bill
-- ===========================================================================

CREATE OR REPLACE FUNCTION public.extra_work_guard()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  IF current_user NOT IN ('authenticated', 'anon') THEN
    RETURN NEW;
  END IF;

  IF TG_OP = 'INSERT' THEN
    NEW.status := 'pending';
    NEW.mechanic_id := public.auth_staff_id();
    NEW.rejection_reason := NULL;
    NEW.customer_response_at := NULL;
    RETURN NEW;
  END IF;

  NEW.id := OLD.id;
  NEW.order_id := OLD.order_id;
  NEW.mechanic_id := OLD.mechanic_id;
  NEW.created_at := OLD.created_at;

  -- Only the requesting mechanic edits the quote, and only while pending.
  -- Otherwise a customer could approve with estimated_cost = 0.
  IF NOT COALESCE(OLD.status = 'pending' AND OLD.mechanic_id = public.auth_staff_id(), false) THEN
    NEW.description := OLD.description;
    NEW.photo_url := OLD.photo_url;
    NEW.estimated_cost := OLD.estimated_cost;
  END IF;

  -- Approve/reject is the customer's (or the shop's) call. RLS alone does not
  -- stop the mechanic: PostgreSQL ORs WITH CHECK across policies, so the
  -- mechanic's own-request USING plus the customer policy's WITH CHECK
  -- allowed a mechanic to approve their own quote.
  IF NEW.status IS DISTINCT FROM OLD.status
     AND NOT (
       public.order_belongs_to_user(OLD.order_id)
       OR public.order_belongs_to_user_company(OLD.order_id)
     ) THEN
    RAISE EXCEPTION 'Only the customer or the shop can respond to extra work' USING ERRCODE = '42501';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_extra_work_guard ON extra_work_requests;
CREATE TRIGGER trg_extra_work_guard
  BEFORE INSERT OR UPDATE ON extra_work_requests
  FOR EACH ROW
  EXECUTE FUNCTION public.extra_work_guard();

ALTER TABLE extra_work_requests DROP CONSTRAINT IF EXISTS extra_work_estimated_cost_nonneg;
ALTER TABLE extra_work_requests
  ADD CONSTRAINT extra_work_estimated_cost_nonneg CHECK (estimated_cost >= 0) NOT VALID;

ALTER TABLE parts_replaced DROP CONSTRAINT IF EXISTS parts_replaced_cost_nonneg;
ALTER TABLE parts_replaced
  ADD CONSTRAINT parts_replaced_cost_nonneg CHECK (cost IS NULL OR cost >= 0) NOT VALID;

-- ===========================================================================
-- 9. Generic images table (vehicle photos)
-- ===========================================================================

DROP POLICY IF EXISTS "Authenticated users can upload images" ON images;
DROP POLICY IF EXISTS "Owners can add images" ON images;
CREATE POLICY "Owners can add images"
  ON images FOR INSERT
  TO authenticated
  WITH CHECK (
    (entity_type::text = 'vehicle' AND entity_id IN (SELECT id FROM vehicles WHERE user_id = auth.uid()))
    OR (entity_type::text = 'company' AND entity_id = user_company_id())
    OR (entity_type::text = 'plan' AND plan_belongs_to_user_company(entity_id))
    OR (entity_type::text = 'service' AND entity_id IN (SELECT id FROM services WHERE company_id = user_company_id()))
    OR (entity_type::text = 'order' AND (order_belongs_to_user(entity_id) OR order_belongs_to_user_company(entity_id)))
  );

DROP POLICY IF EXISTS "Anyone can view images" ON images;
DROP POLICY IF EXISTS "Images are visible to their audience" ON images;
CREATE POLICY "Images are visible to their audience"
  ON images FOR SELECT
  TO public
  USING (
    entity_type::text <> 'vehicle'
    OR entity_id IN (SELECT id FROM vehicles WHERE user_id = auth.uid())
    OR vehicle_on_company_order(entity_id)
    OR vehicle_on_assigned_order(entity_id)
  );

-- ===========================================================================
-- 10. Tables defined outside sql/migrations
-- ===========================================================================

DO $$
BEGIN
  -- sql/orders.sql matched staff by raw JWT email: every mechanic could edit
  -- every order's service details.
  IF to_regclass('public.order_service_details') IS NOT NULL THEN
    ALTER TABLE public.order_service_details ENABLE ROW LEVEL SECURITY;
    DROP POLICY IF EXISTS "Company staff can view their company order service details" ON public.order_service_details;
    DROP POLICY IF EXISTS "Company staff can insert/update order service details" ON public.order_service_details;
    DROP POLICY IF EXISTS "Shop admins manage order service details" ON public.order_service_details;
    DROP POLICY IF EXISTS "Assigned staff manage order service details" ON public.order_service_details;
    CREATE POLICY "Shop admins manage order service details"
      ON public.order_service_details FOR ALL
      TO authenticated
      USING (order_belongs_to_user_company(order_id))
      WITH CHECK (order_belongs_to_user_company(order_id));
    CREATE POLICY "Assigned staff manage order service details"
      ON public.order_service_details FOR ALL
      TO authenticated
      USING (staff_assigned_to_order(order_id, ARRAY['active']::assignment_status[]))
      WITH CHECK (staff_assigned_to_order(order_id, ARRAY['active']::assignment_status[]));
  END IF;

  -- spanr_app/sql/addresses.sql. Only add policies if none exist, so an
  -- already-configured table is left alone.
  IF to_regclass('public.addresses') IS NOT NULL THEN
    ALTER TABLE public.addresses ENABLE ROW LEVEL SECURITY;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'addresses') THEN
      CREATE POLICY "Users can manage own addresses"
        ON public.addresses FOR ALL
        TO authenticated
        USING (user_id = auth.uid())
        WITH CHECK (user_id = auth.uid());
    END IF;
  END IF;
END $$;

-- ===========================================================================
-- 11. RPC authorization fixes
-- ===========================================================================

-- Was: any staff (or anyone passing someone else's p_staff_id) could complete
-- any order in any shop, because the "admin" branch never checked the order's
-- company and user_company_id() was non-null for every mechanic.
CREATE OR REPLACE FUNCTION complete_job(
  p_order_id UUID,
  p_staff_id UUID,
  p_odometer INTEGER DEFAULT NULL,
  p_service_notes TEXT DEFAULT NULL,
  p_services_performed TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_history_id UUID;
  v_caller_staff_id UUID;
  v_order_company UUID;
  v_order_status TEXT;
BEGIN
  v_caller_staff_id := auth_staff_id();
  IF v_caller_staff_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated as staff';
  END IF;

  SELECT company_id, status::text INTO v_order_company, v_order_status
  FROM orders
  WHERE id = p_order_id;

  IF v_order_company IS NULL THEN
    RAISE EXCEPTION 'Order not found';
  END IF;

  IF v_order_status IN ('completed', 'cancelled') THEN
    RAISE EXCEPTION 'Order is already %', v_order_status;
  END IF;

  IF p_staff_id IS DISTINCT FROM v_caller_staff_id THEN
    -- Completing on a mechanic's behalf is an owner/admin action in that shop.
    IF user_company_id() IS DISTINCT FROM v_order_company THEN
      RAISE EXCEPTION 'Not authorized to complete this job';
    END IF;
    IF NOT EXISTS (
      SELECT 1 FROM staff WHERE id = p_staff_id AND company_id = v_order_company
    ) THEN
      RAISE EXCEPTION 'Staff member not found in company';
    END IF;
  ELSIF NOT EXISTS (
    SELECT 1
    FROM order_assignments oa
    WHERE oa.order_id = p_order_id
      AND oa.staff_id = p_staff_id
      AND oa.status = 'active'
  ) THEN
    RAISE EXCEPTION 'No active assignment for this staff member on order';
  END IF;

  INSERT INTO vehicle_service_history (
    order_id,
    vehicle_id,
    company_id,
    staff_id,
    customer_id,
    vehicle_make,
    vehicle_model,
    vehicle_year,
    license_plate,
    customer_name,
    mechanic_name,
    company_name,
    odometer_reading,
    services_performed,
    service_notes
  )
  SELECT
    o.id,
    o.vehicle_id,
    o.company_id,
    p_staff_id,
    o.user_id,
    v.make,
    v.model,
    v.year,
    v.license_plate,
    u.name,
    st.name,
    mc.company_name,
    p_odometer,
    COALESCE(p_services_performed, p.name),
    p_service_notes
  FROM orders o
  JOIN vehicles v ON v.id = o.vehicle_id
  JOIN users u ON u.id = o.user_id
  JOIN plans p ON p.id = o.plan_id
  JOIN mechanic_companies mc ON mc.id = o.company_id
  LEFT JOIN staff st ON st.id = p_staff_id
  WHERE o.id = p_order_id
  RETURNING id INTO v_history_id;

  UPDATE parts_replaced
  SET service_history_id = v_history_id
  WHERE order_id = p_order_id
    AND service_history_id IS NULL;

  UPDATE inspection_images
  SET service_history_id = v_history_id
  WHERE order_id = p_order_id
    AND service_history_id IS NULL;

  UPDATE order_assignments
  SET status = 'completed',
      ended_at = NOW()
  WHERE order_id = p_order_id
    AND status = 'active';

  UPDATE orders
  SET status = 'completed'
  WHERE id = p_order_id;

  UPDATE staff_profiles
  SET availability = 'available'
  WHERE staff_id = p_staff_id;

  RETURN v_history_id;
END;
$$;

-- Was `v_company_id <> user_company_id()`: NULL for non-staff, so the check
-- never fired and any signed-in user could reassign any order.
CREATE OR REPLACE FUNCTION assign_order_to_staff(
  p_order_id UUID,
  p_staff_id UUID,
  p_notes TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_company_id UUID;
  v_assignment_id UUID;
  v_assigner_id UUID;
BEGIN
  v_assigner_id := auth_staff_id();

  SELECT company_id INTO v_company_id
  FROM orders
  WHERE id = p_order_id;

  IF v_company_id IS NULL THEN
    RAISE EXCEPTION 'Order not found';
  END IF;

  IF user_company_id() IS DISTINCT FROM v_company_id THEN
    RAISE EXCEPTION 'Not authorized to assign this order';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM staff
    WHERE id = p_staff_id
      AND company_id = v_company_id
      AND enabled = true
  ) THEN
    RAISE EXCEPTION 'Staff member not found in company';
  END IF;

  UPDATE order_assignments
  SET status = 'reassigned',
      ended_at = NOW()
  WHERE order_id = p_order_id
    AND status = 'active';

  INSERT INTO order_assignments (order_id, staff_id, assigned_by, notes, status)
  VALUES (p_order_id, p_staff_id, v_assigner_id, p_notes, 'active')
  RETURNING id INTO v_assignment_id;

  UPDATE orders
  SET status = 'assigned'
  WHERE id = p_order_id
    AND status IN ('accepted', 'assigned');

  RETURN v_assignment_id;
END;
$$;

-- Was: while admin_users is empty, ANY caller (anon included) could make any
-- account a Super Admin with access to every shop's KYC documents. Seed the
-- first admin from the SQL editor instead:
--   INSERT INTO admin_users (user_id, email)
--   SELECT id, email FROM auth.users WHERE email = '<admin email>';
CREATE OR REPLACE FUNCTION admin_add_admin(target_email TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_target_id UUID;
BEGIN
  IF NOT is_super_admin() THEN
    RAISE EXCEPTION 'Only existing admins can add new admins' USING ERRCODE = '42501';
  END IF;

  SELECT id INTO v_target_id FROM auth.users WHERE email = target_email LIMIT 1;
  IF v_target_id IS NULL THEN
    RAISE EXCEPTION 'No Supabase Auth account found for %. Ask them to sign up first, then retry.', target_email;
  END IF;

  INSERT INTO admin_users (user_id, email)
  VALUES (v_target_id, target_email)
  ON CONFLICT (user_id) DO NOTHING;
END;
$$;

-- ===========================================================================
-- 12. Storage
-- ===========================================================================
-- Public buckets serve /object/public/... URLs without RLS, so getPublicUrl()
-- keeps working. The old "public can SELECT" policies only added the ability
-- to LIST every object (every customer's vehicle photos), and the old
-- UPDATE/DELETE policies let any login overwrite or delete anyone's files.

UPDATE storage.buckets
SET file_size_limit = 10485760,
    allowed_mime_types = ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'application/pdf']
WHERE id = 'company-documents';

UPDATE storage.buckets
SET file_size_limit = 5242880,
    allowed_mime_types = ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/gif']
WHERE id IN ('company-logos', 'company-images', 'service-icons', 'plan-images');

UPDATE storage.buckets
SET file_size_limit = 10485760,
    allowed_mime_types = ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/heic', 'image/heif']
WHERE id IN ('vehicle-images', 'extra-work-photos');

DROP POLICY IF EXISTS "Staff can upload company documents" ON storage.objects;
DROP POLICY IF EXISTS "Staff can read own company documents" ON storage.objects;
DROP POLICY IF EXISTS "Staff can update company documents" ON storage.objects;
DROP POLICY IF EXISTS "Staff can delete company documents" ON storage.objects;
DROP POLICY IF EXISTS "Public can view order images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated can upload order images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated can update order images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated can delete order images" ON storage.objects;
DROP POLICY IF EXISTS "Public can view staff photos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated can upload staff photos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated can update staff photos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated can delete staff photos" ON storage.objects;
DROP POLICY IF EXISTS "Public can view inspection images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated can upload inspection images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated can update inspection images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated can delete inspection images" ON storage.objects;
DROP POLICY IF EXISTS "Public can view staff certificates" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated can upload staff certificates" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated can update staff certificates" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated can delete staff certificates" ON storage.objects;
DROP POLICY IF EXISTS "Mechanics can upload extra work photos" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can view extra work photos" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can view company logos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload company logos" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their company logos" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their company logos" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can view company images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload company images" ON storage.objects;
DROP POLICY IF EXISTS "Users can update company images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete company images" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can view service icons" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload service icons" ON storage.objects;
DROP POLICY IF EXISTS "Users can update service icons" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete service icons" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can view plan images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload plan images" ON storage.objects;
DROP POLICY IF EXISTS "Users can update plan images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete plan images" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can view vehicle images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload vehicle images" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their vehicle images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their vehicle images" ON storage.objects;

-- KYC (private): paths are <company_id>/<doc>-<ts>.<ext>.
DROP POLICY IF EXISTS "company-documents: shop admins upload" ON storage.objects;
CREATE POLICY "company-documents: shop admins upload"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'company-documents'
    AND (storage.foldername(name))[1] = public.user_company_id()::text
  );

DROP POLICY IF EXISTS "company-documents: shop admins and SPANR read" ON storage.objects;
CREATE POLICY "company-documents: shop admins and SPANR read"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'company-documents'
    AND (
      (storage.foldername(name))[1] = public.user_company_id()::text
      OR public.is_super_admin()
    )
  );

DROP POLICY IF EXISTS "company-documents: shop admins update" ON storage.objects;
CREATE POLICY "company-documents: shop admins update"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'company-documents'
    AND (storage.foldername(name))[1] = public.user_company_id()::text
  )
  WITH CHECK (
    bucket_id = 'company-documents'
    AND (storage.foldername(name))[1] = public.user_company_id()::text
  );

DROP POLICY IF EXISTS "company-documents: shop admins delete" ON storage.objects;
CREATE POLICY "company-documents: shop admins delete"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'company-documents'
    AND (storage.foldername(name))[1] = public.user_company_id()::text
  );

-- Public buckets: who may upload, and uploader-only read/update/delete
-- (SELECT is needed for upsert and remove()).
DO $$
DECLARE
  b RECORD;
BEGIN
  FOR b IN
    SELECT * FROM (VALUES
      -- Customer before-photos and shop after-photos.
      ('orders', 'auth.uid() IS NOT NULL'),
      ('vehicle-images', 'auth.uid() IS NOT NULL'),
      -- Mechanic uploads: <order_id>/...
      ('inspection-images',
        'public.staff_assigned_to_order(public.try_uuid((storage.foldername(name))[1]), ARRAY[''active'']::public.assignment_status[])'
        || ' OR public.order_belongs_to_user_company(public.try_uuid((storage.foldername(name))[1]))'),
      ('extra-work-photos',
        'public.staff_assigned_to_order(public.try_uuid((storage.foldername(name))[1]), ARRAY[''active'']::public.assignment_status[])'
        || ' OR public.order_belongs_to_user_company(public.try_uuid((storage.foldername(name))[1]))'),
      -- Dashboard staff files: <staff_id>/...
      ('staff-photos',
        'public.try_uuid((storage.foldername(name))[1]) IN (SELECT id FROM public.staff WHERE company_id = public.user_company_id())'),
      ('staff-certificates',
        'public.try_uuid((storage.foldername(name))[1]) IN (SELECT id FROM public.staff WHERE company_id = public.user_company_id())'),
      -- Shop catalogue assets.
      ('company-logos', 'public.user_company_id() IS NOT NULL'),
      ('company-images', 'public.user_company_id() IS NOT NULL'),
      ('service-icons', 'public.user_company_id() IS NOT NULL'),
      ('plan-images', 'public.user_company_id() IS NOT NULL')
    ) AS t(bucket, upload_check)
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON storage.objects', b.bucket || ': upload');
    EXECUTE format(
      'CREATE POLICY %I ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = %L AND (%s))',
      b.bucket || ': upload', b.bucket, b.upload_check
    );

    EXECUTE format('DROP POLICY IF EXISTS %I ON storage.objects', b.bucket || ': uploader read');
    EXECUTE format(
      'CREATE POLICY %I ON storage.objects FOR SELECT TO authenticated USING (bucket_id = %L AND owner_id = (auth.uid())::text)',
      b.bucket || ': uploader read', b.bucket
    );

    EXECUTE format('DROP POLICY IF EXISTS %I ON storage.objects', b.bucket || ': uploader update');
    EXECUTE format(
      'CREATE POLICY %I ON storage.objects FOR UPDATE TO authenticated'
      || ' USING (bucket_id = %L AND owner_id = (auth.uid())::text)'
      || ' WITH CHECK (bucket_id = %L AND owner_id = (auth.uid())::text)',
      b.bucket || ': uploader update', b.bucket, b.bucket
    );

    EXECUTE format('DROP POLICY IF EXISTS %I ON storage.objects', b.bucket || ': uploader delete');
    EXECUTE format(
      'CREATE POLICY %I ON storage.objects FOR DELETE TO authenticated USING (bucket_id = %L AND owner_id = (auth.uid())::text)',
      b.bucket || ': uploader delete', b.bucket
    );
  END LOOP;
END $$;

-- ===========================================================================
-- Post-apply checks (run manually; policies are OR'd, so any permissive policy
-- created outside these migrations would reopen a hole):
--
--   SELECT tablename, policyname, cmd, qual, with_check
--   FROM pg_policies
--   WHERE schemaname IN ('public', 'storage')
--     AND (qual IN ('true', '(true)') OR with_check IN ('true', '(true)'));
--
--   SELECT c.company_name, s.name, s.email, s.role
--   FROM staff s JOIN mechanic_companies c ON c.id = s.company_id
--   ORDER BY c.company_name, s.role;
-- ===========================================================================

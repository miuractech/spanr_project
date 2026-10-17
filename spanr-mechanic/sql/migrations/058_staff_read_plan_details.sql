-- Mechanics need plan contents on the job screen (features, steps, catalog
-- jobs). Match staff by auth uid / JWT email so this works whether or not
-- user_company_id() is owner-only.

DROP POLICY IF EXISTS "Staff can view own shop plan features" ON plan_features;
CREATE POLICY "Staff can view own shop plan features"
  ON plan_features FOR SELECT
  TO authenticated
  USING (
    plan_id IN (
      SELECT p.id
      FROM plans p
      JOIN staff s ON s.company_id = p.company_id
      WHERE s.enabled = true
        AND (
          s.auth_user_id = auth.uid()
          OR (auth.jwt()->>'email' IS NOT NULL AND s.email = auth.jwt()->>'email')
        )
    )
  );

DROP POLICY IF EXISTS "Staff can view own shop plan steps" ON plan_steps;
CREATE POLICY "Staff can view own shop plan steps"
  ON plan_steps FOR SELECT
  TO authenticated
  USING (
    plan_id IN (
      SELECT p.id
      FROM plans p
      JOIN staff s ON s.company_id = p.company_id
      WHERE s.enabled = true
        AND (
          s.auth_user_id = auth.uid()
          OR (auth.jwt()->>'email' IS NOT NULL AND s.email = auth.jwt()->>'email')
        )
    )
  );

DROP POLICY IF EXISTS "Staff can view own shop plan extras" ON plan_additional_services;
CREATE POLICY "Staff can view own shop plan extras"
  ON plan_additional_services FOR SELECT
  TO authenticated
  USING (
    plan_id IN (
      SELECT p.id
      FROM plans p
      JOIN staff s ON s.company_id = p.company_id
      WHERE s.enabled = true
        AND (
          s.auth_user_id = auth.uid()
          OR (auth.jwt()->>'email' IS NOT NULL AND s.email = auth.jwt()->>'email')
        )
    )
  );

DROP POLICY IF EXISTS "Staff can view own shop plan jobs" ON plan_included_jobs;
CREATE POLICY "Staff can view own shop plan jobs"
  ON plan_included_jobs FOR SELECT
  TO authenticated
  USING (
    plan_id IN (
      SELECT p.id
      FROM plans p
      JOIN staff s ON s.company_id = p.company_id
      WHERE s.enabled = true
        AND (
          s.auth_user_id = auth.uid()
          OR (auth.jwt()->>'email' IS NOT NULL AND s.email = auth.jwt()->>'email')
        )
    )
  );

DROP POLICY IF EXISTS "Staff can view own shop job catalog" ON job_catalog;
CREATE POLICY "Staff can view own shop job catalog"
  ON job_catalog FOR SELECT
  TO authenticated
  USING (
    company_id IN (
      SELECT s.company_id
      FROM staff s
      WHERE s.enabled = true
        AND (
          s.auth_user_id = auth.uid()
          OR (auth.jwt()->>'email' IS NOT NULL AND s.email = auth.jwt()->>'email')
        )
    )
  );

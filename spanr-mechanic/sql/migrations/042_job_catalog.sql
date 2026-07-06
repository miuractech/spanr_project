-- =====================================================
-- Job catalog for the new services model
-- job_sections: groups of jobs (Engine, Wheel, etc.)
-- job_catalog:  individual jobs with price + thumbnail
-- plan changes: plan_type (package|custom), package_tier (1|2|3)
-- plan_included_jobs: which catalog jobs a package plan includes
-- order_selected_jobs: jobs a customer picks for a custom-plan order
-- =====================================================

-- Job sections (e.g. Engine, Wheel, Suspension, Handle)
CREATE TABLE IF NOT EXISTS job_sections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES mechanic_companies(id) ON DELETE CASCADE,
  vehicle_type TEXT NOT NULL CHECK (vehicle_type IN ('car', 'bike')),
  name TEXT NOT NULL,
  image_url TEXT,
  display_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_job_sections_updated_at
  BEFORE UPDATE ON job_sections
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE INDEX IF NOT EXISTS idx_job_sections_company ON job_sections(company_id);

ALTER TABLE job_sections ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Staff can manage their shop job sections"
  ON job_sections FOR ALL
  TO authenticated
  USING (company_id = user_company_id());

-- Customers can read job sections (for custom plan display in the app)
CREATE POLICY "Customers can read job sections"
  ON job_sections FOR SELECT
  TO authenticated
  USING (true);

-- Individual jobs within a section
CREATE TABLE IF NOT EXISTS job_catalog (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES mechanic_companies(id) ON DELETE CASCADE,
  section_id UUID NOT NULL REFERENCES job_sections(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  thumbnail_url TEXT,
  base_price NUMERIC(10,2) NOT NULL DEFAULT 0,
  display_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_job_catalog_updated_at
  BEFORE UPDATE ON job_catalog
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE INDEX IF NOT EXISTS idx_job_catalog_company ON job_catalog(company_id);
CREATE INDEX IF NOT EXISTS idx_job_catalog_section ON job_catalog(section_id);

ALTER TABLE job_catalog ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Staff can manage their shop job catalog"
  ON job_catalog FOR ALL
  TO authenticated
  USING (company_id = user_company_id());

CREATE POLICY "Customers can read job catalog"
  ON job_catalog FOR SELECT
  TO authenticated
  USING (true);

-- Add plan_type and package_tier to plans table
ALTER TABLE plans
  ADD COLUMN IF NOT EXISTS plan_type TEXT NOT NULL DEFAULT 'package'
    CHECK (plan_type IN ('package', 'custom')),
  ADD COLUMN IF NOT EXISTS package_tier INTEGER
    CHECK (package_tier IS NULL OR package_tier IN (1, 2, 3));

-- Jobs included in a package plan (many-to-many)
CREATE TABLE IF NOT EXISTS plan_included_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id UUID NOT NULL REFERENCES plans(id) ON DELETE CASCADE,
  job_id UUID NOT NULL REFERENCES job_catalog(id) ON DELETE CASCADE,
  UNIQUE (plan_id, job_id)
);

ALTER TABLE plan_included_jobs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Staff can manage plan included jobs"
  ON plan_included_jobs FOR ALL
  TO authenticated
  USING (
    plan_id IN (SELECT id FROM plans WHERE company_id = user_company_id())
  );

CREATE POLICY "Customers can read plan included jobs"
  ON plan_included_jobs FOR SELECT
  TO authenticated
  USING (true);

-- Jobs selected by a customer at booking time (for custom plan orders)
CREATE TABLE IF NOT EXISTS order_selected_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  job_id UUID NOT NULL REFERENCES job_catalog(id) ON DELETE RESTRICT,
  issue_description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_order_selected_jobs_order ON order_selected_jobs(order_id);

ALTER TABLE order_selected_jobs ENABLE ROW LEVEL SECURITY;

-- Staff can view selected jobs for their company's orders
CREATE POLICY "Staff can view order selected jobs"
  ON order_selected_jobs FOR SELECT
  TO authenticated
  USING (
    order_id IN (SELECT id FROM orders WHERE company_id = user_company_id())
  );

-- Customers can view and insert their own order's selected jobs
CREATE POLICY "Customers can manage their order selected jobs"
  ON order_selected_jobs FOR ALL
  TO authenticated
  USING (
    order_id IN (SELECT id FROM orders WHERE user_id = auth.uid())
  )
  WITH CHECK (
    order_id IN (SELECT id FROM orders WHERE user_id = auth.uid())
  );

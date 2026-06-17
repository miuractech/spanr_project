-- Staff certificates, courses, attendance, and part before/after photos

CREATE TABLE IF NOT EXISTS staff_certificates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  staff_id UUID NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  file_url TEXT NOT NULL,
  expiry_date DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS staff_courses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  staff_id UUID NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
  course_name TEXT NOT NULL,
  institution TEXT,
  completed_date DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS staff_attendance (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  staff_id UUID NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
  company_id UUID NOT NULL REFERENCES mechanic_companies(id) ON DELETE CASCADE,
  check_in_date DATE NOT NULL DEFAULT CURRENT_DATE,
  check_in_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(staff_id, check_in_date)
);

ALTER TABLE parts_replaced ADD COLUMN IF NOT EXISTS before_photo_url TEXT;

CREATE INDEX IF NOT EXISTS idx_staff_certificates_staff_id ON staff_certificates(staff_id);
CREATE INDEX IF NOT EXISTS idx_staff_courses_staff_id ON staff_courses(staff_id);
CREATE INDEX IF NOT EXISTS idx_staff_attendance_staff_id ON staff_attendance(staff_id);
CREATE INDEX IF NOT EXISTS idx_staff_attendance_company_date ON staff_attendance(company_id, check_in_date);

-- staff_certificates RLS
ALTER TABLE staff_certificates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Staff can view company certificates"
  ON staff_certificates FOR SELECT
  TO authenticated
  USING (
    staff_id IN (SELECT id FROM staff WHERE company_id = user_company_id())
    OR staff_id = auth_staff_id()
  );

CREATE POLICY "Staff can manage company certificates"
  ON staff_certificates FOR ALL
  TO authenticated
  USING (
    staff_id IN (SELECT id FROM staff WHERE company_id = user_company_id())
  )
  WITH CHECK (
    staff_id IN (SELECT id FROM staff WHERE company_id = user_company_id())
  );

-- staff_courses RLS
ALTER TABLE staff_courses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Staff can view company courses"
  ON staff_courses FOR SELECT
  TO authenticated
  USING (
    staff_id IN (SELECT id FROM staff WHERE company_id = user_company_id())
    OR staff_id = auth_staff_id()
  );

CREATE POLICY "Staff can manage company courses"
  ON staff_courses FOR ALL
  TO authenticated
  USING (
    staff_id IN (SELECT id FROM staff WHERE company_id = user_company_id())
  )
  WITH CHECK (
    staff_id IN (SELECT id FROM staff WHERE company_id = user_company_id())
  );

-- staff_attendance RLS
ALTER TABLE staff_attendance ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Staff can view company attendance"
  ON staff_attendance FOR SELECT
  TO authenticated
  USING (
    company_id = user_company_id()
    OR staff_id = auth_staff_id()
  );

CREATE POLICY "Staff can mark own attendance"
  ON staff_attendance FOR INSERT
  TO authenticated
  WITH CHECK (staff_id = auth_staff_id());

-- staff-certificates storage bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'staff-certificates',
  'staff-certificates',
  true,
  10485760,
  ARRAY['image/jpeg', 'image/png', 'image/jpg', 'image/webp', 'application/pdf']
)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Public can view staff certificates" ON storage.objects;
CREATE POLICY "Public can view staff certificates"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'staff-certificates');

DROP POLICY IF EXISTS "Authenticated can upload staff certificates" ON storage.objects;
CREATE POLICY "Authenticated can upload staff certificates"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'staff-certificates');

DROP POLICY IF EXISTS "Authenticated can update staff certificates" ON storage.objects;
CREATE POLICY "Authenticated can update staff certificates"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'staff-certificates');

DROP POLICY IF EXISTS "Authenticated can delete staff certificates" ON storage.objects;
CREATE POLICY "Authenticated can delete staff certificates"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'staff-certificates');

-- =====================================================
-- Staff profiles, skills, and auth link
-- =====================================================

CREATE TYPE staff_availability AS ENUM ('available', 'busy', 'off');

ALTER TABLE staff ADD COLUMN IF NOT EXISTS auth_user_id UUID REFERENCES auth.users(id);

CREATE TABLE IF NOT EXISTS staff_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  staff_id UUID NOT NULL UNIQUE REFERENCES staff(id) ON DELETE CASCADE,
  phone TEXT,
  experience_years INTEGER NOT NULL DEFAULT 0,
  photo_url TEXT,
  availability staff_availability NOT NULL DEFAULT 'available',
  bio TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS staff_skills (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  staff_id UUID NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
  skill_name TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(staff_id, skill_name)
);

CREATE INDEX IF NOT EXISTS idx_staff_profiles_staff_id ON staff_profiles(staff_id);
CREATE INDEX IF NOT EXISTS idx_staff_skills_staff_id ON staff_skills(staff_id);
CREATE INDEX IF NOT EXISTS idx_staff_auth_user_id ON staff(auth_user_id);

DROP TRIGGER IF EXISTS update_staff_profiles_updated_at ON staff_profiles;
CREATE TRIGGER update_staff_profiles_updated_at
  BEFORE UPDATE ON staff_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

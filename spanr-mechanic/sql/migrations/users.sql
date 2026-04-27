
-- Users table (customers)
-- id is the auth.uid() from Supabase Auth (UUID)
CREATE TABLE users (
  id UUID PRIMARY KEY, -- This is auth.uid(), no default needed
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

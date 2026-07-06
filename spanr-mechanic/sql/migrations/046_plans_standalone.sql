-- Plans no longer require a service category.
-- service_id is kept for backward compat but made nullable.
ALTER TABLE plans ALTER COLUMN service_id DROP NOT NULL;

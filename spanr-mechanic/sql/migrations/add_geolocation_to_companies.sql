-- Add latitude and longitude columns to mechanic_companies table
-- This migration adds geolocation support for mechanic companies

ALTER TABLE mechanic_companies
ADD COLUMN IF NOT EXISTS latitude NUMERIC(10, 8),
ADD COLUMN IF NOT EXISTS longitude NUMERIC(11, 8);

-- Create index for better performance on location queries
CREATE INDEX IF NOT EXISTS idx_mechanic_companies_latitude ON mechanic_companies(latitude);
CREATE INDEX IF NOT EXISTS idx_mechanic_companies_longitude ON mechanic_companies(longitude);

-- Create a composite index for geospatial queries
CREATE INDEX IF NOT EXISTS idx_mechanic_companies_geolocation ON mechanic_companies(latitude, longitude);


-- Add latitude, longitude, and images to mechanic_companies table
ALTER TABLE mechanic_companies
ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS images TEXT[] DEFAULT '{}';

-- Add comment for new columns
COMMENT ON COLUMN mechanic_companies.latitude IS 'Company location latitude';
COMMENT ON COLUMN mechanic_companies.longitude IS 'Company location longitude';
COMMENT ON COLUMN mechanic_companies.images IS 'Array of company banner/image URLs';


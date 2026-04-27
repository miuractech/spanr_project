-- Helper queries for vehicle management

-- Vehicle table schema:
-- id, user_id, name, make, model, year, color, license_plate, 
-- vehicle_type (car/bike), is_primary, is_indian_licensed, 
-- created_at, updated_at

-- Get all vehicles for a user with images
SELECT 
  v.*,
  COALESCE(
    json_agg(
      json_build_object('url', i.url)
    ) FILTER (WHERE i.id IS NOT NULL),
    '[]'
  ) as images
FROM vehicles v
LEFT JOIN images i ON i.entity_id = v.id AND i.entity_type = 'vehicle'
WHERE v.user_id = 'auth-uid'::uuid
GROUP BY v.id
ORDER BY v.is_primary DESC, v.created_at DESC;

-- Get vehicle by ID with images
SELECT 
  v.*,
  COALESCE(
    json_agg(
      json_build_object('url', i.url)
    ) FILTER (WHERE i.id IS NOT NULL),
    '[]'
  ) as images
FROM vehicles v
LEFT JOIN images i ON i.entity_id = v.id AND i.entity_type = 'vehicle'
WHERE v.id = 'vehicle-uuid'::uuid
AND v.user_id = 'auth-uid'::uuid
GROUP BY v.id;

-- Create new vehicle
INSERT INTO vehicles (
  user_id, name, make, model, year, color, 
  license_plate, vehicle_type, is_primary, is_indian_licensed
)
VALUES (
  'auth-uid'::uuid,
  'My Car',
  'Toyota',
  'Camry',
  2020,
  'White',
  'ABC123',
  'car',
  true,
  true
)
RETURNING *;

-- Update vehicle
UPDATE vehicles
SET 
  name = 'Updated Name',
  make = 'Honda',
  model = 'Accord',
  year = 2021,
  color = 'Black',
  license_plate = 'XYZ789',
  vehicle_type = 'car',
  is_primary = false,
  is_indian_licensed = true
WHERE id = 'vehicle-uuid'::uuid
AND user_id = 'auth-uid'::uuid
RETURNING *;

-- Delete vehicle (images will cascade)
DELETE FROM vehicles
WHERE id = 'vehicle-uuid'::uuid
AND user_id = 'auth-uid'::uuid;

-- Add image to vehicle
INSERT INTO images (entity_type, entity_id, url, file_name)
VALUES ('vehicle', 'vehicle-uuid', 'image-url', 'file-name.jpg')
RETURNING *;

-- Get all images for a vehicle
SELECT * FROM images
WHERE entity_type = 'vehicle'
AND entity_id = 'vehicle-uuid'
ORDER BY created_at;

-- Delete specific image
DELETE FROM images
WHERE entity_type = 'vehicle'
AND entity_id = 'vehicle-uuid'
AND url = 'image-url';


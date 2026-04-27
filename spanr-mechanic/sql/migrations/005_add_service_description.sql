-- Add description field to services table
-- This allows services to have detailed descriptions

ALTER TABLE services
ADD COLUMN description TEXT;

-- Add index for better search performance
CREATE INDEX idx_services_company_category ON services(company_id, category);

-- Add index for plans by service
CREATE INDEX idx_plans_service_id ON plans(service_id);

-- Add comment to clarify the relationship
COMMENT ON TABLE services IS 'Services offered by mechanic companies (e.g., "Bike Repair", "Car Maintenance"). Each service can have multiple plans.';
COMMENT ON TABLE plans IS 'Service plans under a specific service (e.g., "Full Service", "Deluxe Service"). Each plan belongs to one service and has specific pricing.';
COMMENT ON COLUMN plans.service_id IS 'References the parent service. Multiple plans can belong to one service with different pricing tiers.';


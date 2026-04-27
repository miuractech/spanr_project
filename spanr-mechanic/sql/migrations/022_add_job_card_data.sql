-- Add job_card_data JSONB column to order_service_details
-- Stores mechanic-fillable job card fields

ALTER TABLE order_service_details
  ADD COLUMN IF NOT EXISTS job_card_data JSONB;

-- =====================================================
-- Extend order_status enum for job assignment workflow
-- =====================================================

ALTER TYPE order_status ADD VALUE IF NOT EXISTS 'assigned' AFTER 'accepted';
ALTER TYPE order_status ADD VALUE IF NOT EXISTS 'waiting_for_parts' AFTER 'in_progress';

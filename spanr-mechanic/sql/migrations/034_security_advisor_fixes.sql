-- Fix Supabase security advisor warnings

-- Views: use invoker permissions so underlying table RLS applies
ALTER VIEW staff_workload SET (security_invoker = true);
ALTER VIEW order_details SET (security_invoker = true);
ALTER VIEW company_profiles SET (security_invoker = true);

-- Webhook audit table: service-role only (edge function)
ALTER TABLE payment_webhook_events ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON payment_webhook_events FROM anon, authenticated;

-- Explicit deny for API roles; edge function uses service role
CREATE POLICY "No direct client access to webhook events"
  ON payment_webhook_events
  FOR ALL
  TO authenticated
  USING (false)
  WITH CHECK (false);

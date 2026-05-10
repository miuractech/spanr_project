-- Allow customers to update payment rows for their own orders (Razorpay processing fields only).
-- Clients must not set status = paid; only the webhook (service role) does.
DROP POLICY IF EXISTS "Users can update their own payments" ON payments;

CREATE POLICY "Users can update their own payments"
  ON payments FOR UPDATE
  TO authenticated
  USING (
    order_id IN (
      SELECT id FROM orders WHERE user_id = auth.uid()
    )
  )
  WITH CHECK (
    order_id IN (
      SELECT id FROM orders WHERE user_id = auth.uid()
    )
    AND (status = ANY (ARRAY['unpaid'::payment_status, 'processing'::payment_status]))
  );

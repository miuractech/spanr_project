-- Company staff (owners/admins) can approve or reject extra work requests
-- for orders belonging to their company.
-- Previously only customers and mechanics had UPDATE policies — dashboard
-- approvals were silently blocked by RLS.
CREATE POLICY "Company staff can respond to extra work requests"
  ON extra_work_requests FOR UPDATE
  TO authenticated
  USING (
    order_id IN (SELECT id FROM orders WHERE company_id = user_company_id())
    AND status = 'pending'
  )
  WITH CHECK (
    status IN ('approved', 'rejected')
  );

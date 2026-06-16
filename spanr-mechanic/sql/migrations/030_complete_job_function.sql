-- =====================================================
-- Complete job RPC — creates permanent service history
-- =====================================================

CREATE OR REPLACE FUNCTION complete_job(
  p_order_id UUID,
  p_staff_id UUID,
  p_odometer INTEGER DEFAULT NULL,
  p_service_notes TEXT DEFAULT NULL,
  p_services_performed TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_history_id UUID;
  v_caller_staff_id UUID;
BEGIN
  v_caller_staff_id := auth_staff_id();

  IF v_caller_staff_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated as staff';
  END IF;

  IF p_staff_id IS DISTINCT FROM v_caller_staff_id THEN
    IF user_company_id() IS NULL THEN
      RAISE EXCEPTION 'Not authorized to complete this job';
    END IF;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM order_assignments oa
    WHERE oa.order_id = p_order_id
      AND oa.staff_id = p_staff_id
      AND oa.status = 'active'
  ) AND p_staff_id = v_caller_staff_id THEN
    RAISE EXCEPTION 'No active assignment for this staff member on order';
  END IF;

  INSERT INTO vehicle_service_history (
    order_id,
    vehicle_id,
    company_id,
    staff_id,
    customer_id,
    vehicle_make,
    vehicle_model,
    vehicle_year,
    license_plate,
    customer_name,
    mechanic_name,
    company_name,
    odometer_reading,
    services_performed,
    service_notes
  )
  SELECT
    o.id,
    o.vehicle_id,
    o.company_id,
    p_staff_id,
    o.user_id,
    v.make,
    v.model,
    v.year,
    v.license_plate,
    u.name,
    st.name,
    mc.company_name,
    p_odometer,
    COALESCE(p_services_performed, p.name),
    p_service_notes
  FROM orders o
  JOIN vehicles v ON v.id = o.vehicle_id
  JOIN users u ON u.id = o.user_id
  JOIN plans p ON p.id = o.plan_id
  JOIN mechanic_companies mc ON mc.id = o.company_id
  LEFT JOIN staff st ON st.id = p_staff_id
  WHERE o.id = p_order_id
  RETURNING id INTO v_history_id;

  UPDATE parts_replaced
  SET service_history_id = v_history_id
  WHERE order_id = p_order_id
    AND service_history_id IS NULL;

  UPDATE inspection_images
  SET service_history_id = v_history_id
  WHERE order_id = p_order_id
    AND service_history_id IS NULL;

  UPDATE order_assignments
  SET status = 'completed',
      ended_at = NOW()
  WHERE order_id = p_order_id
    AND status = 'active';

  UPDATE orders
  SET status = 'completed'
  WHERE id = p_order_id;

  UPDATE staff_profiles
  SET availability = 'available'
  WHERE staff_id = p_staff_id;

  RETURN v_history_id;
END;
$$;

GRANT EXECUTE ON FUNCTION assign_order_to_staff(UUID, UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION complete_job(UUID, UUID, INTEGER, TEXT, TEXT) TO authenticated;

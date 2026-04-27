-- Seed: 2 services (Car & Bike) + 15 plans each
-- Company: 79ae05fa-2af3-481e-8d7f-70d5fc155cc0

DO $$
DECLARE
  car_service_id UUID;
  bike_service_id UUID;
BEGIN

  -- =====================================================
  -- SERVICES
  -- =====================================================

  INSERT INTO services (company_id, name, category)
  VALUES ('79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Car Service', 'car')
  RETURNING id INTO car_service_id;

  INSERT INTO services (company_id, name, category)
  VALUES ('79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Bike Service', 'bike')
  RETURNING id INTO bike_service_id;

  -- =====================================================
  -- CAR PLANS (15)
  -- =====================================================

  -- 1
  INSERT INTO plans (service_id, company_id, name, vehicle_type, location_type, duration, base_price, tax, warranty, guarantee, badge)
  VALUES (car_service_id, '79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Basic Oil Change', 'car', 'in_premise', 45, 599.00, 18.00, '1 month', NULL, NULL);

  -- 2
  INSERT INTO plans (service_id, company_id, name, vehicle_type, location_type, duration, base_price, tax, warranty, guarantee, badge)
  VALUES (car_service_id, '79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Standard Full Service', 'car', 'in_premise', 180, 2499.00, 18.00, '3 months', '30 days', 'Popular');

  -- 3
  INSERT INTO plans (service_id, company_id, name, vehicle_type, location_type, duration, base_price, tax, warranty, guarantee, badge)
  VALUES (car_service_id, '79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Comprehensive Full Service', 'car', 'in_premise', 240, 3999.00, 18.00, '6 months', '60 days', 'Best Value');

  -- 4
  INSERT INTO plans (service_id, company_id, name, vehicle_type, location_type, duration, base_price, tax, warranty, guarantee, badge)
  VALUES (car_service_id, '79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'AC Service & Regas', 'car', 'in_premise', 120, 1799.00, 18.00, '3 months', NULL, NULL);

  -- 5
  INSERT INTO plans (service_id, company_id, name, vehicle_type, location_type, duration, base_price, tax, warranty, guarantee, badge)
  VALUES (car_service_id, '79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Brake Inspection & Replacement', 'car', 'in_premise', 90, 1299.00, 18.00, '6 months', NULL, NULL);

  -- 6
  INSERT INTO plans (service_id, company_id, name, vehicle_type, location_type, duration, base_price, tax, warranty, guarantee, badge)
  VALUES (car_service_id, '79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Wheel Alignment & Balancing', 'car', 'in_premise', 60, 799.00, 18.00, '1 month', NULL, NULL);

  -- 7
  INSERT INTO plans (service_id, company_id, name, vehicle_type, location_type, duration, base_price, tax, warranty, guarantee, badge)
  VALUES (car_service_id, '79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Battery Replacement', 'car', 'in_premise', 30, 3499.00, 18.00, '12 months', NULL, NULL);

  -- 8
  INSERT INTO plans (service_id, company_id, name, vehicle_type, location_type, duration, base_price, tax, warranty, guarantee, badge)
  VALUES (car_service_id, '79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Engine Diagnostics', 'car', 'in_premise', 60, 999.00, 18.00, NULL, NULL, NULL);

  -- 9
  INSERT INTO plans (service_id, company_id, name, vehicle_type, location_type, duration, base_price, tax, warranty, guarantee, badge)
  VALUES (car_service_id, '79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Coolant Flush & Refill', 'car', 'in_premise', 45, 699.00, 18.00, '3 months', NULL, NULL);

  -- 10
  INSERT INTO plans (service_id, company_id, name, vehicle_type, location_type, duration, base_price, tax, warranty, guarantee, badge)
  VALUES (car_service_id, '79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Transmission Service', 'car', 'in_premise', 150, 2999.00, 18.00, '6 months', '30 days', NULL);

  -- 11
  INSERT INTO plans (service_id, company_id, name, vehicle_type, location_type, duration, base_price, tax, warranty, guarantee, badge)
  VALUES (car_service_id, '79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Spark Plug Replacement', 'car', 'in_premise', 60, 899.00, 18.00, '6 months', NULL, NULL);

  -- 12
  INSERT INTO plans (service_id, company_id, name, vehicle_type, location_type, duration, base_price, tax, warranty, guarantee, badge)
  VALUES (car_service_id, '79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Air Filter Replacement', 'car', 'in_premise', 20, 399.00, 18.00, '3 months', NULL, NULL);

  -- 13
  INSERT INTO plans (service_id, company_id, name, vehicle_type, location_type, duration, base_price, tax, warranty, guarantee, badge)
  VALUES (car_service_id, '79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Suspension Check & Service', 'car', 'in_premise', 120, 1999.00, 18.00, '6 months', NULL, NULL);

  -- 14
  INSERT INTO plans (service_id, company_id, name, vehicle_type, location_type, duration, base_price, tax, warranty, guarantee, badge)
  VALUES (car_service_id, '79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Interior & Exterior Detailing', 'car', 'in_premise', 180, 2199.00, 18.00, NULL, NULL, NULL);

  -- 15
  INSERT INTO plans (service_id, company_id, name, vehicle_type, location_type, duration, base_price, tax, warranty, guarantee, badge)
  VALUES (car_service_id, '79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Doorstep Full Service', 'car', 'shed', 240, 4499.00, 18.00, '3 months', '30 days', 'Doorstep');

  -- =====================================================
  -- BIKE PLANS (15)
  -- =====================================================

  -- 1
  INSERT INTO plans (service_id, company_id, name, vehicle_type, location_type, duration, base_price, tax, warranty, guarantee, badge)
  VALUES (bike_service_id, '79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Basic Bike Service', 'bike', 'in_premise', 60, 299.00, 18.00, '1 month', NULL, NULL);

  -- 2
  INSERT INTO plans (service_id, company_id, name, vehicle_type, location_type, duration, base_price, tax, warranty, guarantee, badge)
  VALUES (bike_service_id, '79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Standard Full Service', 'bike', 'in_premise', 120, 899.00, 18.00, '3 months', '30 days', 'Popular');

  -- 3
  INSERT INTO plans (service_id, company_id, name, vehicle_type, location_type, duration, base_price, tax, warranty, guarantee, badge)
  VALUES (bike_service_id, '79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Comprehensive Full Service', 'bike', 'in_premise', 180, 1499.00, 18.00, '6 months', '60 days', 'Best Value');

  -- 4
  INSERT INTO plans (service_id, company_id, name, vehicle_type, location_type, duration, base_price, tax, warranty, guarantee, badge)
  VALUES (bike_service_id, '79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Oil Change', 'bike', 'in_premise', 30, 249.00, 18.00, '1 month', NULL, NULL);

  -- 5
  INSERT INTO plans (service_id, company_id, name, vehicle_type, location_type, duration, base_price, tax, warranty, guarantee, badge)
  VALUES (bike_service_id, '79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Chain & Sprocket Replacement', 'bike', 'in_premise', 60, 799.00, 18.00, '6 months', NULL, NULL);

  -- 6
  INSERT INTO plans (service_id, company_id, name, vehicle_type, location_type, duration, base_price, tax, warranty, guarantee, badge)
  VALUES (bike_service_id, '79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Tyre Replacement (Both)', 'bike', 'in_premise', 45, 1999.00, 18.00, '12 months', NULL, NULL);

  -- 7
  INSERT INTO plans (service_id, company_id, name, vehicle_type, location_type, duration, base_price, tax, warranty, guarantee, badge)
  VALUES (bike_service_id, '79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Battery Replacement', 'bike', 'in_premise', 20, 1299.00, 18.00, '12 months', NULL, NULL);

  -- 8
  INSERT INTO plans (service_id, company_id, name, vehicle_type, location_type, duration, base_price, tax, warranty, guarantee, badge)
  VALUES (bike_service_id, '79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Brake Pads Replacement', 'bike', 'in_premise', 30, 499.00, 18.00, '6 months', NULL, NULL);

  -- 9
  INSERT INTO plans (service_id, company_id, name, vehicle_type, location_type, duration, base_price, tax, warranty, guarantee, badge)
  VALUES (bike_service_id, '79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Carburetor Cleaning & Tuning', 'bike', 'in_premise', 60, 599.00, 18.00, '1 month', NULL, NULL);

  -- 10
  INSERT INTO plans (service_id, company_id, name, vehicle_type, location_type, duration, base_price, tax, warranty, guarantee, badge)
  VALUES (bike_service_id, '79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Suspension Service', 'bike', 'in_premise', 90, 999.00, 18.00, '6 months', NULL, NULL);

  -- 11
  INSERT INTO plans (service_id, company_id, name, vehicle_type, location_type, duration, base_price, tax, warranty, guarantee, badge)
  VALUES (bike_service_id, '79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Spark Plug Replacement', 'bike', 'in_premise', 20, 199.00, 18.00, '3 months', NULL, NULL);

  -- 12
  INSERT INTO plans (service_id, company_id, name, vehicle_type, location_type, duration, base_price, tax, warranty, guarantee, badge)
  VALUES (bike_service_id, '79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Air Filter Replacement', 'bike', 'in_premise', 15, 149.00, 18.00, '3 months', NULL, NULL);

  -- 13
  INSERT INTO plans (service_id, company_id, name, vehicle_type, location_type, duration, base_price, tax, warranty, guarantee, badge)
  VALUES (bike_service_id, '79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Engine Diagnostics', 'bike', 'in_premise', 45, 499.00, 18.00, NULL, NULL, NULL);

  -- 14
  INSERT INTO plans (service_id, company_id, name, vehicle_type, location_type, duration, base_price, tax, warranty, guarantee, badge)
  VALUES (bike_service_id, '79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Fuel Injection Cleaning', 'bike', 'in_premise', 60, 699.00, 18.00, '1 month', NULL, NULL);

  -- 15
  INSERT INTO plans (service_id, company_id, name, vehicle_type, location_type, duration, base_price, tax, warranty, guarantee, badge)
  VALUES (bike_service_id, '79ae05fa-2af3-481e-8d7f-70d5fc155cc0', 'Doorstep Full Service', 'bike', 'shed', 150, 1799.00, 18.00, '3 months', '30 days', 'Doorstep');

END $$;

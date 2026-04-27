-- Seed: Plan features, steps, additional services, FAQs, outcomes
-- Company: 79ae05fa-2af3-481e-8d7f-70d5fc155cc0
-- Reference plans by name + company_id

DO $$
DECLARE
  cid UUID := '79ae05fa-2af3-481e-8d7f-70d5fc155cc0';

  -- CAR plans
  p_car_basic_oil         UUID;
  p_car_std_full          UUID;
  p_car_comp_full         UUID;
  p_car_ac                UUID;
  p_car_brake             UUID;
  p_car_wheel             UUID;
  p_car_battery           UUID;
  p_car_engine_diag       UUID;
  p_car_coolant           UUID;
  p_car_transmission      UUID;
  p_car_spark             UUID;
  p_car_air_filter        UUID;
  p_car_suspension        UUID;
  p_car_detailing         UUID;
  p_car_doorstep          UUID;

  -- BIKE plans
  p_bike_basic            UUID;
  p_bike_std_full         UUID;
  p_bike_comp_full        UUID;
  p_bike_oil              UUID;
  p_bike_chain            UUID;
  p_bike_tyre             UUID;
  p_bike_battery          UUID;
  p_bike_brake            UUID;
  p_bike_carb             UUID;
  p_bike_suspension       UUID;
  p_bike_spark            UUID;
  p_bike_air_filter       UUID;
  p_bike_engine_diag      UUID;
  p_bike_fuel_inj         UUID;
  p_bike_doorstep         UUID;

BEGIN

  SELECT id INTO p_car_basic_oil    FROM plans WHERE company_id = cid AND name = 'Basic Oil Change'                  AND vehicle_type = 'car';
  SELECT id INTO p_car_std_full     FROM plans WHERE company_id = cid AND name = 'Standard Full Service'             AND vehicle_type = 'car';
  SELECT id INTO p_car_comp_full    FROM plans WHERE company_id = cid AND name = 'Comprehensive Full Service'        AND vehicle_type = 'car';
  SELECT id INTO p_car_ac           FROM plans WHERE company_id = cid AND name = 'AC Service & Regas'                AND vehicle_type = 'car';
  SELECT id INTO p_car_brake        FROM plans WHERE company_id = cid AND name = 'Brake Inspection & Replacement'    AND vehicle_type = 'car';
  SELECT id INTO p_car_wheel        FROM plans WHERE company_id = cid AND name = 'Wheel Alignment & Balancing'       AND vehicle_type = 'car';
  SELECT id INTO p_car_battery      FROM plans WHERE company_id = cid AND name = 'Battery Replacement'               AND vehicle_type = 'car';
  SELECT id INTO p_car_engine_diag  FROM plans WHERE company_id = cid AND name = 'Engine Diagnostics'                AND vehicle_type = 'car';
  SELECT id INTO p_car_coolant      FROM plans WHERE company_id = cid AND name = 'Coolant Flush & Refill'            AND vehicle_type = 'car';
  SELECT id INTO p_car_transmission FROM plans WHERE company_id = cid AND name = 'Transmission Service'              AND vehicle_type = 'car';
  SELECT id INTO p_car_spark        FROM plans WHERE company_id = cid AND name = 'Spark Plug Replacement'            AND vehicle_type = 'car';
  SELECT id INTO p_car_air_filter   FROM plans WHERE company_id = cid AND name = 'Air Filter Replacement'            AND vehicle_type = 'car';
  SELECT id INTO p_car_suspension   FROM plans WHERE company_id = cid AND name = 'Suspension Check & Service'        AND vehicle_type = 'car';
  SELECT id INTO p_car_detailing    FROM plans WHERE company_id = cid AND name = 'Interior & Exterior Detailing'     AND vehicle_type = 'car';
  SELECT id INTO p_car_doorstep     FROM plans WHERE company_id = cid AND name = 'Doorstep Full Service'             AND vehicle_type = 'car';

  SELECT id INTO p_bike_basic       FROM plans WHERE company_id = cid AND name = 'Basic Bike Service'                AND vehicle_type = 'bike';
  SELECT id INTO p_bike_std_full    FROM plans WHERE company_id = cid AND name = 'Standard Full Service'             AND vehicle_type = 'bike';
  SELECT id INTO p_bike_comp_full   FROM plans WHERE company_id = cid AND name = 'Comprehensive Full Service'        AND vehicle_type = 'bike';
  SELECT id INTO p_bike_oil         FROM plans WHERE company_id = cid AND name = 'Oil Change'                        AND vehicle_type = 'bike';
  SELECT id INTO p_bike_chain       FROM plans WHERE company_id = cid AND name = 'Chain & Sprocket Replacement'      AND vehicle_type = 'bike';
  SELECT id INTO p_bike_tyre        FROM plans WHERE company_id = cid AND name = 'Tyre Replacement (Both)'           AND vehicle_type = 'bike';
  SELECT id INTO p_bike_battery     FROM plans WHERE company_id = cid AND name = 'Battery Replacement'               AND vehicle_type = 'bike';
  SELECT id INTO p_bike_brake       FROM plans WHERE company_id = cid AND name = 'Brake Pads Replacement'            AND vehicle_type = 'bike';
  SELECT id INTO p_bike_carb        FROM plans WHERE company_id = cid AND name = 'Carburetor Cleaning & Tuning'      AND vehicle_type = 'bike';
  SELECT id INTO p_bike_suspension  FROM plans WHERE company_id = cid AND name = 'Suspension Service'                AND vehicle_type = 'bike';
  SELECT id INTO p_bike_spark       FROM plans WHERE company_id = cid AND name = 'Spark Plug Replacement'            AND vehicle_type = 'bike';
  SELECT id INTO p_bike_air_filter  FROM plans WHERE company_id = cid AND name = 'Air Filter Replacement'            AND vehicle_type = 'bike';
  SELECT id INTO p_bike_engine_diag FROM plans WHERE company_id = cid AND name = 'Engine Diagnostics'                AND vehicle_type = 'bike';
  SELECT id INTO p_bike_fuel_inj    FROM plans WHERE company_id = cid AND name = 'Fuel Injection Cleaning'           AND vehicle_type = 'bike';
  SELECT id INTO p_bike_doorstep    FROM plans WHERE company_id = cid AND name = 'Doorstep Full Service'             AND vehicle_type = 'bike';

  -- =====================================================
  -- CAR: Basic Oil Change
  -- =====================================================
  INSERT INTO plan_features (plan_id, feature, display_order) VALUES
    (p_car_basic_oil, 'Engine oil drain & refill with quality oil', 1),
    (p_car_basic_oil, 'Oil filter replacement', 2),
    (p_car_basic_oil, 'Multi-point visual inspection', 3),
    (p_car_basic_oil, 'Top-up of all fluid levels', 4);

  INSERT INTO plan_steps (plan_id, step_description, display_order) VALUES
    (p_car_basic_oil, 'Vehicle check-in and mileage recorded', 1),
    (p_car_basic_oil, 'Old engine oil drained completely', 2),
    (p_car_basic_oil, 'Oil filter removed and replaced', 3),
    (p_car_basic_oil, 'Fresh engine oil filled to specification', 4),
    (p_car_basic_oil, 'Fluid levels checked and topped up', 5),
    (p_car_basic_oil, 'Post-service test and handover', 6);

  INSERT INTO plan_faqs (plan_id, question, answer, display_order) VALUES
    (p_car_basic_oil, 'What type of oil will be used?', 'We use manufacturer-recommended mineral or semi-synthetic oil based on your vehicle spec.', 1),
    (p_car_basic_oil, 'How often should I change my engine oil?', 'Typically every 5,000–10,000 km or every 6 months, whichever comes first.', 2),
    (p_car_basic_oil, 'Will the oil filter always be replaced?', 'Yes, a new OEM-compatible oil filter is included with every oil change.', 3);

  INSERT INTO plan_service_outcomes (plan_id, title, image_url, description, display_order) VALUES
    (p_car_basic_oil, 'Smoother Engine Performance', '', 'Fresh oil reduces friction and heat, resulting in a noticeably smoother and quieter engine.', 1),
    (p_car_basic_oil, 'Extended Engine Life', '', 'Regular oil changes prevent sludge buildup and protect engine components from premature wear.', 2);

  -- =====================================================
  -- CAR: Standard Full Service
  -- =====================================================
  INSERT INTO plan_features (plan_id, feature, display_order) VALUES
    (p_car_std_full, 'Engine oil & filter change', 1),
    (p_car_std_full, 'Air filter inspection & cleaning', 2),
    (p_car_std_full, 'Brake inspection (front & rear)', 3),
    (p_car_std_full, 'Tyre pressure check & rotation', 4),
    (p_car_std_full, 'Battery health check', 5),
    (p_car_std_full, 'All fluid levels topped up', 6);

  INSERT INTO plan_steps (plan_id, step_description, display_order) VALUES
    (p_car_std_full, 'Vehicle reception and initial inspection', 1),
    (p_car_std_full, 'Engine oil drained and replaced with fresh oil', 2),
    (p_car_std_full, 'Air filter inspected and cleaned or replaced', 3),
    (p_car_std_full, 'Brake pads and discs measured and reported', 4),
    (p_car_std_full, 'Tyre pressure adjusted and tread depth checked', 5),
    (p_car_std_full, 'Battery voltage tested and terminals cleaned', 6),
    (p_car_std_full, 'All fluid levels topped up', 7),
    (p_car_std_full, 'Road test and final sign-off', 8);

  INSERT INTO plan_additional_services (plan_id, service_name, display_order) VALUES
    (p_car_std_full, 'Cabin air filter replacement', 1),
    (p_car_std_full, 'Wiper blade replacement', 2),
    (p_car_std_full, 'Wheel alignment check', 3);

  INSERT INTO plan_faqs (plan_id, question, answer, display_order) VALUES
    (p_car_std_full, 'How long does the service take?', 'Approximately 3 hours including road test.', 1),
    (p_car_std_full, 'Is a service report provided?', 'Yes, a detailed digital report is shared after the service.', 2),
    (p_car_std_full, 'Do I need to leave my car overnight?', 'No, the standard service is completed same day.', 3),
    (p_car_std_full, 'What if additional parts are needed?', 'You will be notified with a cost estimate before any extra work begins.', 4);

  INSERT INTO plan_service_outcomes (plan_id, title, image_url, description, display_order) VALUES
    (p_car_std_full, 'Peak Engine Health', '', 'Fresh fluids and clean filters keep the engine running at optimal efficiency.', 1),
    (p_car_std_full, 'Improved Fuel Economy', '', 'Clean air filters and proper tyre pressure can improve fuel efficiency by up to 10%.', 2),
    (p_car_std_full, 'Enhanced Safety', '', 'Inspected brakes and tyres reduce the risk of on-road incidents.', 3);

  -- =====================================================
  -- CAR: Comprehensive Full Service
  -- =====================================================
  INSERT INTO plan_features (plan_id, feature, display_order) VALUES
    (p_car_comp_full, 'All items in Standard Full Service', 1),
    (p_car_comp_full, 'Spark plug inspection & replacement', 2),
    (p_car_comp_full, 'Coolant flush & refill', 3),
    (p_car_comp_full, 'Transmission fluid check', 4),
    (p_car_comp_full, 'Suspension & steering inspection', 5),
    (p_car_comp_full, 'Engine diagnostics scan (OBD-II)', 6),
    (p_car_comp_full, 'Fuel system cleaning', 7);

  INSERT INTO plan_steps (plan_id, step_description, display_order) VALUES
    (p_car_comp_full, 'Full vehicle reception & OBD-II scan', 1),
    (p_car_comp_full, 'Engine oil, filter & spark plugs replaced', 2),
    (p_car_comp_full, 'Coolant flushed and refilled', 3),
    (p_car_comp_full, 'Transmission fluid level verified', 4),
    (p_car_comp_full, 'Suspension joints and steering checked', 5),
    (p_car_comp_full, 'All brakes, tyres, and fluid levels serviced', 6),
    (p_car_comp_full, 'Fuel injectors cleaned', 7),
    (p_car_comp_full, 'Road test and comprehensive report issued', 8);

  INSERT INTO plan_additional_services (plan_id, service_name, display_order) VALUES
    (p_car_comp_full, 'Wheel alignment & balancing', 1),
    (p_car_comp_full, 'AC gas top-up', 2),
    (p_car_comp_full, 'Engine flush add-on', 3);

  INSERT INTO plan_faqs (plan_id, question, answer, display_order) VALUES
    (p_car_comp_full, 'What makes this different from standard service?', 'It includes deeper drivetrain checks, OBD diagnostics, coolant flush, and spark plug replacement.', 1),
    (p_car_comp_full, 'How often should I do a comprehensive service?', 'Every 20,000 km or once a year, whichever comes first.', 2),
    (p_car_comp_full, 'Is this suitable for older vehicles?', 'Yes, this service is especially beneficial for vehicles over 3 years old.', 3);

  INSERT INTO plan_service_outcomes (plan_id, title, image_url, description, display_order) VALUES
    (p_car_comp_full, 'Like-New Engine Feel', '', 'Deep cleaning and all critical replacements restore near-new performance.', 1),
    (p_car_comp_full, 'Zero Hidden Issues', '', 'OBD diagnostics surface any underlying faults before they become costly repairs.', 2),
    (p_car_comp_full, 'Maximum Reliability', '', 'All wear items addressed so you can drive confidently for the next 20,000 km.', 3);

  -- =====================================================
  -- CAR: AC Service & Regas
  -- =====================================================
  INSERT INTO plan_features (plan_id, feature, display_order) VALUES
    (p_car_ac, 'AC system pressure check', 1),
    (p_car_ac, 'Refrigerant gas top-up / regas', 2),
    (p_car_ac, 'Cabin air filter cleaning or replacement', 3),
    (p_car_ac, 'AC vent temperature measurement', 4),
    (p_car_ac, 'Leak detection test', 5);

  INSERT INTO plan_steps (plan_id, step_description, display_order) VALUES
    (p_car_ac, 'System pressure tested with manifold gauge', 1),
    (p_car_ac, 'Old refrigerant recovered safely', 2),
    (p_car_ac, 'Leak test performed on all connections', 3),
    (p_car_ac, 'Fresh refrigerant charged to spec', 4),
    (p_car_ac, 'Cabin filter cleaned or replaced', 5),
    (p_car_ac, 'Vent temperature verified at target cooling level', 6);

  INSERT INTO plan_faqs (plan_id, question, answer, display_order) VALUES
    (p_car_ac, 'How do I know my AC needs a regas?', 'Warm air from vents, reduced cooling, or AC compressor cycling on/off frequently are common signs.', 1),
    (p_car_ac, 'What refrigerant is used?', 'R134a or R1234yf depending on your vehicle model year.', 2),
    (p_car_ac, 'How long does AC stay cool after a regas?', 'Typically 1–2 years under normal usage with no leaks.', 3);

  INSERT INTO plan_service_outcomes (plan_id, title, image_url, description, display_order) VALUES
    (p_car_ac, 'Ice-Cold Cabin Air', '', 'Properly recharged refrigerant delivers maximum cooling efficiency.', 1),
    (p_car_ac, 'Improved Air Quality', '', 'Clean cabin filter removes dust, pollen, and bacteria from circulated air.', 2);

  -- =====================================================
  -- CAR: Brake Inspection & Replacement
  -- =====================================================
  INSERT INTO plan_features (plan_id, feature, display_order) VALUES
    (p_car_brake, 'Front and rear brake pad measurement', 1),
    (p_car_brake, 'Brake disc thickness check', 2),
    (p_car_brake, 'Brake fluid level and condition check', 3),
    (p_car_brake, 'Caliper and handbrake inspection', 4),
    (p_car_brake, 'Replacement of worn pads if required', 5);

  INSERT INTO plan_steps (plan_id, step_description, display_order) VALUES
    (p_car_brake, 'Wheels removed for full brake access', 1),
    (p_car_brake, 'Pad thickness measured front and rear', 2),
    (p_car_brake, 'Disc run-out and thickness checked', 3),
    (p_car_brake, 'Worn pads replaced with quality parts', 4),
    (p_car_brake, 'Caliper sliders lubricated', 5),
    (p_car_brake, 'Brake fluid topped up and bleeding checked', 6),
    (p_car_brake, 'Test drive to bed in new pads', 7);

  INSERT INTO plan_faqs (plan_id, question, answer, display_order) VALUES
    (p_car_brake, 'When should brake pads be replaced?', 'Generally when they reach 3mm thickness or less, or if you hear squealing.', 1),
    (p_car_brake, 'Will you replace all four wheels?', 'We inspect all four and replace only what is worn; you are informed of each decision.', 2),
    (p_car_brake, 'Is brake disc replacement included?', 'Disc replacement is quoted separately if needed during inspection.', 3);

  INSERT INTO plan_service_outcomes (plan_id, title, image_url, description, display_order) VALUES
    (p_car_brake, 'Shorter Stopping Distance', '', 'New pads restore full braking power for maximum safety.', 1),
    (p_car_brake, 'Silent Braking', '', 'Eliminating worn pads removes the squeal and grinding noise.', 2),
    (p_car_brake, 'Protected Brake Discs', '', 'Timely pad replacement prevents expensive disc damage.', 3);

  -- =====================================================
  -- CAR: Wheel Alignment & Balancing
  -- =====================================================
  INSERT INTO plan_features (plan_id, feature, display_order) VALUES
    (p_car_wheel, '4-wheel computerised alignment', 1),
    (p_car_wheel, 'All four tyres dynamically balanced', 2),
    (p_car_wheel, 'Tyre pressure set to spec', 3),
    (p_car_wheel, 'Tread depth check on all tyres', 4);

  INSERT INTO plan_steps (plan_id, step_description, display_order) VALUES
    (p_car_wheel, 'Vehicle positioned on alignment rack', 1),
    (p_car_wheel, 'Current alignment angles measured', 2),
    (p_car_wheel, 'Camber, caster, and toe adjusted', 3),
    (p_car_wheel, 'Wheels removed and balanced on balancer', 4),
    (p_car_wheel, 'Tyre pressure set and tread depth noted', 5),
    (p_car_wheel, 'Short test drive to verify straight tracking', 6);

  INSERT INTO plan_faqs (plan_id, question, answer, display_order) VALUES
    (p_car_wheel, 'How do I know my wheels are misaligned?', 'Pulling to one side, uneven tyre wear, or a vibrating steering wheel are common signs.', 1),
    (p_car_wheel, 'How often should alignment be done?', 'Every 10,000 km or after hitting a large pothole or kerb.', 2),
    (p_car_wheel, 'Is balancing different from alignment?', 'Yes—balancing corrects vibration from uneven weight distribution; alignment corrects steering angles.', 3);

  INSERT INTO plan_service_outcomes (plan_id, title, image_url, description, display_order) VALUES
    (p_car_wheel, 'Straight, Vibration-Free Drive', '', 'Correct alignment and balance eliminate steering pull and wheel vibration.', 1),
    (p_car_wheel, 'Even Tyre Wear', '', 'Proper alignment extends tyre life by ensuring even contact with the road.', 2);

  -- =====================================================
  -- CAR: Battery Replacement
  -- =====================================================
  INSERT INTO plan_features (plan_id, feature, display_order) VALUES
    (p_car_battery, 'Old battery safely removed and disposed', 1),
    (p_car_battery, 'New OEM-grade battery fitted', 2),
    (p_car_battery, 'Terminal corrosion cleaned and protected', 3),
    (p_car_battery, 'Charging system (alternator) health check', 4),
    (p_car_battery, '12-month warranty on battery', 5);

  INSERT INTO plan_steps (plan_id, step_description, display_order) VALUES
    (p_car_battery, 'Battery load test to confirm failure', 1),
    (p_car_battery, 'Vehicle electronics protected before removal', 2),
    (p_car_battery, 'Old battery removed and recycled', 3),
    (p_car_battery, 'New battery installed and terminals secured', 4),
    (p_car_battery, 'Alternator output voltage verified', 5),
    (p_car_battery, 'ECU adaptations reset if required', 6);

  INSERT INTO plan_faqs (plan_id, question, answer, display_order) VALUES
    (p_car_battery, 'How long does a car battery last?', 'Typically 3–5 years depending on usage and climate.', 1),
    (p_car_battery, 'Will my settings be lost after replacement?', 'We use a memory saver to preserve radio and ECU settings where possible.', 2),
    (p_car_battery, 'What battery brands are used?', 'We use reputed brands such as Amaron, Exide, or Bosch based on your vehicle requirement.', 3);

  INSERT INTO plan_service_outcomes (plan_id, title, image_url, description, display_order) VALUES
    (p_car_battery, 'Reliable Cold Starts', '', 'A fresh battery ensures your car starts instantly every time.', 1),
    (p_car_battery, 'Stable Electrical System', '', 'Correct battery voltage prevents glitches in electronics, lights, and sensors.', 2);

  -- =====================================================
  -- CAR: Engine Diagnostics
  -- =====================================================
  INSERT INTO plan_features (plan_id, feature, display_order) VALUES
    (p_car_engine_diag, 'Full OBD-II fault code scan', 1),
    (p_car_engine_diag, 'Live data stream analysis', 2),
    (p_car_engine_diag, 'Check engine light diagnosis', 3),
    (p_car_engine_diag, 'Detailed diagnostic report', 4),
    (p_car_engine_diag, 'Repair recommendation with cost estimate', 5);

  INSERT INTO plan_steps (plan_id, step_description, display_order) VALUES
    (p_car_engine_diag, 'OBD-II scanner connected to vehicle port', 1),
    (p_car_engine_diag, 'All stored and pending fault codes retrieved', 2),
    (p_car_engine_diag, 'Live sensor data analysed at idle and rev', 3),
    (p_car_engine_diag, 'Fault codes cross-referenced with vehicle database', 4),
    (p_car_engine_diag, 'Report prepared with prioritised repair actions', 5);

  INSERT INTO plan_faqs (plan_id, question, answer, display_order) VALUES
    (p_car_engine_diag, 'Will fault codes be cleared after diagnosis?', 'Codes are cleared only after confirmed repair; we note all codes in the report.', 1),
    (p_car_engine_diag, 'Is this suitable for all car makes?', 'Yes, our scanner supports all OBD-II compliant vehicles (2001 onwards).', 2),
    (p_car_engine_diag, 'What if no fault codes are found?', 'We check freeze frame data and live sensor values to identify intermittent issues.', 3);

  INSERT INTO plan_service_outcomes (plan_id, title, image_url, description, display_order) VALUES
    (p_car_engine_diag, 'Clear Picture of Vehicle Health', '', 'Know exactly what is wrong and what can wait, with a prioritised action list.', 1),
    (p_car_engine_diag, 'Prevent Costly Repairs', '', 'Catching faults early avoids escalation into major engine or transmission damage.', 2);

  -- =====================================================
  -- CAR: Coolant Flush & Refill
  -- =====================================================
  INSERT INTO plan_features (plan_id, feature, display_order) VALUES
    (p_car_coolant, 'Full coolant system flush', 1),
    (p_car_coolant, 'Fresh OEM-spec coolant refilled', 2),
    (p_car_coolant, 'Thermostat and radiator cap inspection', 3),
    (p_car_coolant, 'Hose and clamp visual check', 4);

  INSERT INTO plan_steps (plan_id, step_description, display_order) VALUES
    (p_car_coolant, 'Radiator cap removed and coolant condition assessed', 1),
    (p_car_coolant, 'Old coolant drained from radiator and block', 2),
    (p_car_coolant, 'System flushed with clean water', 3),
    (p_car_coolant, 'Fresh coolant mixed to correct ratio and refilled', 4),
    (p_car_coolant, 'System bled to remove air pockets', 5),
    (p_car_coolant, 'Temperature gauge monitored during warm-up', 6);

  INSERT INTO plan_faqs (plan_id, question, answer, display_order) VALUES
    (p_car_coolant, 'How often should coolant be flushed?', 'Every 2 years or 40,000 km as a general guideline.', 1),
    (p_car_coolant, 'Can old coolant damage the engine?', 'Yes, degraded coolant loses anti-corrosion properties and can cause rust inside the cooling system.', 2),
    (p_car_coolant, 'What happens if I mix coolant types?', 'Mixing different coolant types can cause chemical reactions and reduce effectiveness; we always flush fully before refilling.', 3);

  INSERT INTO plan_service_outcomes (plan_id, title, image_url, description, display_order) VALUES
    (p_car_coolant, 'Stable Engine Temperature', '', 'Fresh coolant maintains optimal operating temperature and prevents overheating.', 1),
    (p_car_coolant, 'Corrosion-Free Cooling System', '', 'Correct inhibitor levels protect the radiator, water pump, and engine block.', 2);

  -- =====================================================
  -- CAR: Transmission Service
  -- =====================================================
  INSERT INTO plan_features (plan_id, feature, display_order) VALUES
    (p_car_transmission, 'Transmission fluid drain and refill', 1),
    (p_car_transmission, 'Transmission filter replacement', 2),
    (p_car_transmission, 'Pan gasket inspection and resealing', 3),
    (p_car_transmission, 'Shift quality test before and after', 4),
    (p_car_transmission, 'Leak points inspected and reported', 5);

  INSERT INTO plan_steps (plan_id, step_description, display_order) VALUES
    (p_car_transmission, 'Transmission fluid level and condition checked', 1),
    (p_car_transmission, 'Pan removed and old fluid drained', 2),
    (p_car_transmission, 'Filter and gasket replaced', 3),
    (p_car_transmission, 'Pan refitted and new fluid filled', 4),
    (p_car_transmission, 'Shift quality verified across all gears', 5),
    (p_car_transmission, 'Road test and final report', 6);

  INSERT INTO plan_faqs (plan_id, question, answer, display_order) VALUES
    (p_car_transmission, 'When should transmission fluid be changed?', 'Every 40,000–60,000 km for automatic, or when fluid appears dark and burnt.', 1),
    (p_car_transmission, 'Does this cover both manual and automatic?', 'Yes, we service both manual gearboxes and automatic transmissions.', 2),
    (p_car_transmission, 'What if I feel jerky shifts?', 'Jerky shifting is often resolved by a fluid change; if it persists, further diagnosis is included.', 3);

  INSERT INTO plan_service_outcomes (plan_id, title, image_url, description, display_order) VALUES
    (p_car_transmission, 'Smooth Gear Changes', '', 'Clean fluid restores silky, hesitation-free gear transitions.', 1),
    (p_car_transmission, 'Extended Transmission Life', '', 'Fresh fluid with proper additives prevents clutch and gear wear.', 2);

  -- =====================================================
  -- CAR: Suspension Check & Service
  -- =====================================================
  INSERT INTO plan_features (plan_id, feature, display_order) VALUES
    (p_car_suspension, 'Shock absorber condition check', 1),
    (p_car_suspension, 'Ball joint and tie rod inspection', 2),
    (p_car_suspension, 'Strut mount and bushing assessment', 3),
    (p_car_suspension, 'Wheel bearing play check', 4),
    (p_car_suspension, 'Written report with part wear status', 5);

  INSERT INTO plan_steps (plan_id, step_description, display_order) VALUES
    (p_car_suspension, 'Vehicle raised on lift for full undercarriage access', 1),
    (p_car_suspension, 'Shocks and struts bounce-tested', 2),
    (p_car_suspension, 'Ball joints, tie rods, and bushings inspected for play', 3),
    (p_car_suspension, 'Wheel bearings checked for noise and play', 4),
    (p_car_suspension, 'Worn components replaced if authorised by customer', 5),
    (p_car_suspension, 'Post-service wheel alignment check recommended', 6);

  INSERT INTO plan_faqs (plan_id, question, answer, display_order) VALUES
    (p_car_suspension, 'How do I know if my suspension is failing?', 'Bumpy ride, nose-diving under braking, uneven tyre wear, and clunking noises are common indicators.', 1),
    (p_car_suspension, 'Can you replace shocks during this service?', 'Yes, shock absorber replacement is included in the service if required.', 2),
    (p_car_suspension, 'Is a suspension check necessary if I drive mostly in the city?', 'Yes — city potholes and speed bumps cause significant suspension wear over time.', 3);

  INSERT INTO plan_service_outcomes (plan_id, title, image_url, description, display_order) VALUES
    (p_car_suspension, 'Comfortable, Controlled Ride', '', 'Properly functioning suspension absorbs road imperfections for a smooth driving experience.', 1),
    (p_car_suspension, 'Improved Handling & Safety', '', 'Tight suspension components keep the car stable during cornering and emergency manoeuvres.', 2);

  -- =====================================================
  -- CAR: Interior & Exterior Detailing
  -- =====================================================
  INSERT INTO plan_features (plan_id, feature, display_order) VALUES
    (p_car_detailing, 'Full exterior hand wash and clay bar treatment', 1),
    (p_car_detailing, 'Machine polish and wax coat', 2),
    (p_car_detailing, 'Interior vacuum and steam cleaning', 3),
    (p_car_detailing, 'Dashboard and trim dressing', 4),
    (p_car_detailing, 'Glass cleaning inside and out', 5),
    (p_car_detailing, 'Tyre dressing and alloy wheel clean', 6);

  INSERT INTO plan_steps (plan_id, step_description, display_order) VALUES
    (p_car_detailing, 'Pre-wash rinse and wheel cleaner applied', 1),
    (p_car_detailing, 'Hand wash with pH-neutral shampoo', 2),
    (p_car_detailing, 'Clay bar decontamination on paint', 3),
    (p_car_detailing, 'Machine polishing to remove light scratches', 4),
    (p_car_detailing, 'Wax or sealant applied for paint protection', 5),
    (p_car_detailing, 'Interior vacuumed, mats cleaned', 6),
    (p_car_detailing, 'Steam clean on seats and carpets', 7),
    (p_car_detailing, 'Dashboard, trim, and glass finished', 8);

  INSERT INTO plan_faqs (plan_id, question, answer, display_order) VALUES
    (p_car_detailing, 'How long does a full detail take?', 'Approximately 3 hours for a thorough interior and exterior detail.', 1),
    (p_car_detailing, 'Will polishing remove deep scratches?', 'Light swirl marks and minor scratches are removed; deep scratches require paint correction.', 2),
    (p_car_detailing, 'How often should I get my car detailed?', 'Every 3–6 months to maintain paint protection and interior hygiene.', 3);

  INSERT INTO plan_service_outcomes (plan_id, title, image_url, description, display_order) VALUES
    (p_car_detailing, 'Showroom-Finish Exterior', '', 'Polish and wax restore deep gloss and protect paint from UV and contaminants.', 1),
    (p_car_detailing, 'Fresh, Clean Interior', '', 'Steam cleaning eliminates bacteria, odours, and allergens from the cabin.', 2),
    (p_car_detailing, 'Protected Paint Surface', '', 'Wax coat acts as a sacrificial layer shielding the clear coat from daily wear.', 3);

  -- =====================================================
  -- CAR: Doorstep Full Service
  -- =====================================================
  INSERT INTO plan_features (plan_id, feature, display_order) VALUES
    (p_car_doorstep, 'Everything in Comprehensive Full Service', 1),
    (p_car_doorstep, 'Mechanic arrives at your location', 2),
    (p_car_doorstep, 'Fully equipped mobile service unit', 3),
    (p_car_doorstep, 'No need to drive to a garage', 4),
    (p_car_doorstep, 'Digital report sent post-service', 5);

  INSERT INTO plan_faqs (plan_id, question, answer, display_order) VALUES
    (p_car_doorstep, 'What locations do you cover for doorstep service?', 'We cover a 15 km radius from our service centre. Check availability at booking.', 1),
    (p_car_doorstep, 'Do you need power or water access at my location?', 'A standard power socket is helpful; we carry our own water supply.', 2),
    (p_car_doorstep, 'Is the price higher than in-premise service?', 'Yes, a convenience premium is included for the doorstep experience.', 3);

  INSERT INTO plan_service_outcomes (plan_id, title, image_url, description, display_order) VALUES
    (p_car_doorstep, 'Zero Downtime', '', 'Your car is serviced while you work or relax at home — no trips to the garage.', 1),
    (p_car_doorstep, 'Complete Transparency', '', 'Watch your service happen in real time right in your driveway.', 2);

  -- =====================================================
  -- BIKE: Basic Bike Service
  -- =====================================================
  INSERT INTO plan_features (plan_id, feature, display_order) VALUES
    (p_bike_basic, 'Engine oil & filter change', 1),
    (p_bike_basic, 'Chain lubrication and tension check', 2),
    (p_bike_basic, 'Tyre pressure check', 3),
    (p_bike_basic, 'Brake adjustment', 4),
    (p_bike_basic, 'Lights and horn check', 5);

  INSERT INTO plan_steps (plan_id, step_description, display_order) VALUES
    (p_bike_basic, 'Visual pre-inspection of the bike', 1),
    (p_bike_basic, 'Engine oil drained and replaced', 2),
    (p_bike_basic, 'Chain cleaned, lubricated, and tension set', 3),
    (p_bike_basic, 'Tyre pressure set to spec', 4),
    (p_bike_basic, 'Brakes checked and adjusted', 5),
    (p_bike_basic, 'Lights, horn, and mirrors verified', 6);

  INSERT INTO plan_faqs (plan_id, question, answer, display_order) VALUES
    (p_bike_basic, 'How often should I do a basic service?', 'Every 3,000–5,000 km or every 3 months for daily riders.', 1),
    (p_bike_basic, 'Is oil filter replacement included?', 'Yes, a new oil filter is included with the oil change.', 2),
    (p_bike_basic, 'How long does the service take?', 'Approximately 1 hour.', 3);

  INSERT INTO plan_service_outcomes (plan_id, title, image_url, description, display_order) VALUES
    (p_bike_basic, 'Smooth, Responsive Ride', '', 'Fresh oil and adjusted chain result in a noticeably smoother and more responsive bike.', 1),
    (p_bike_basic, 'Safer Daily Commute', '', 'Checked brakes, lights, and tyres ensure roadworthy safety.', 2);

  -- =====================================================
  -- BIKE: Standard Full Service
  -- =====================================================
  INSERT INTO plan_features (plan_id, feature, display_order) VALUES
    (p_bike_std_full, 'All items in Basic Service', 1),
    (p_bike_std_full, 'Carburetor / throttle body cleaning', 2),
    (p_bike_std_full, 'Spark plug inspection', 3),
    (p_bike_std_full, 'Air filter cleaning', 4),
    (p_bike_std_full, 'Clutch and brake cable adjustment', 5),
    (p_bike_std_full, 'Battery terminal cleaning', 6);

  INSERT INTO plan_steps (plan_id, step_description, display_order) VALUES
    (p_bike_std_full, 'Reception and mileage check', 1),
    (p_bike_std_full, 'Engine oil and filter replaced', 2),
    (p_bike_std_full, 'Carburetor or throttle body cleaned', 3),
    (p_bike_std_full, 'Spark plug inspected and gapped correctly', 4),
    (p_bike_std_full, 'Air filter cleaned or replaced', 5),
    (p_bike_std_full, 'Clutch and brake cables adjusted', 6),
    (p_bike_std_full, 'Chain, tyres, brakes, lights verified', 7),
    (p_bike_std_full, 'Test ride and handover', 8);

  INSERT INTO plan_additional_services (plan_id, service_name, display_order) VALUES
    (p_bike_std_full, 'Spark plug replacement', 1),
    (p_bike_std_full, 'Brake shoe replacement', 2);

  INSERT INTO plan_faqs (plan_id, question, answer, display_order) VALUES
    (p_bike_std_full, 'How is this different from the basic service?', 'Includes carb/throttle cleaning, spark plug and air filter check, and cable adjustments for better performance.', 1),
    (p_bike_std_full, 'How long does it take?', 'Approximately 2 hours.', 2),
    (p_bike_std_full, 'Will I get a service report?', 'Yes, a digital report is shared after the service.', 3);

  INSERT INTO plan_service_outcomes (plan_id, title, image_url, description, display_order) VALUES
    (p_bike_std_full, 'Better Throttle Response', '', 'Clean carburetor or throttle body ensures crisp acceleration.', 1),
    (p_bike_std_full, 'Improved Fuel Efficiency', '', 'Correct air-fuel mixture from a clean carb can improve mileage by 10–15%.', 2),
    (p_bike_std_full, 'Overall Reliability', '', 'Checked cables and all fluids give peace of mind for daily riding.', 3);

  -- =====================================================
  -- BIKE: Comprehensive Full Service
  -- =====================================================
  INSERT INTO plan_features (plan_id, feature, display_order) VALUES
    (p_bike_comp_full, 'All items in Standard Full Service', 1),
    (p_bike_comp_full, 'Engine diagnostics scan', 2),
    (p_bike_comp_full, 'Valve clearance check', 3),
    (p_bike_comp_full, 'Fork oil inspection', 4),
    (p_bike_comp_full, 'Full brake system service', 5),
    (p_bike_comp_full, 'Drive chain replacement assessment', 6);

  INSERT INTO plan_steps (plan_id, step_description, display_order) VALUES
    (p_bike_comp_full, 'OBD scan and fault code retrieval', 1),
    (p_bike_comp_full, 'Engine oil, filter, spark plug replaced', 2),
    (p_bike_comp_full, 'Valve clearances measured and adjusted', 3),
    (p_bike_comp_full, 'Fork oil level and condition inspected', 4),
    (p_bike_comp_full, 'Full brake system inspected and serviced', 5),
    (p_bike_comp_full, 'Chain, sprockets, and all cables serviced', 6),
    (p_bike_comp_full, 'Test ride and comprehensive report', 7);

  INSERT INTO plan_faqs (plan_id, question, answer, display_order) VALUES
    (p_bike_comp_full, 'Is valve adjustment included?', 'Yes, valve clearances are checked and adjusted as part of this service.', 1),
    (p_bike_comp_full, 'How long does the comprehensive service take?', 'Approximately 3 hours.', 2),
    (p_bike_comp_full, 'How often should I do this service?', 'Every 10,000 km or once a year.', 3);

  INSERT INTO plan_service_outcomes (plan_id, title, image_url, description, display_order) VALUES
    (p_bike_comp_full, 'Peak Engine Performance', '', 'Correct valve clearances and clean fuel system restore full engine output.', 1),
    (p_bike_comp_full, 'No Hidden Issues', '', 'OBD diagnostics and full inspection surface any lurking faults.', 2),
    (p_bike_comp_full, 'Complete Ride Confidence', '', 'Every critical system is checked and serviced for maximum safety.', 3);

  -- =====================================================
  -- BIKE: Chain & Sprocket Replacement
  -- =====================================================
  INSERT INTO plan_features (plan_id, feature, display_order) VALUES
    (p_bike_chain, 'Drive chain wear measurement', 1),
    (p_bike_chain, 'Front and rear sprocket wear check', 2),
    (p_bike_chain, 'Chain and sprocket kit replacement', 3),
    (p_bike_chain, 'Chain tension set to spec', 4),
    (p_bike_chain, 'Final wheel alignment check', 5);

  INSERT INTO plan_steps (plan_id, step_description, display_order) VALUES
    (p_bike_chain, 'Chain stretch measured with chain wear tool', 1),
    (p_bike_chain, 'Sprocket teeth inspected for hooking or wear', 2),
    (p_bike_chain, 'Old chain and sprockets removed', 3),
    (p_bike_chain, 'New chain and sprocket kit fitted', 4),
    (p_bike_chain, 'Chain tension and wheel alignment set', 5),
    (p_bike_chain, 'Test ride to confirm smooth power transfer', 6);

  INSERT INTO plan_faqs (plan_id, question, answer, display_order) VALUES
    (p_bike_chain, 'Should I replace sprockets with the chain?', 'Yes, always replace chain and sprockets together to prevent premature wear.', 1),
    (p_bike_chain, 'How do I know when the chain is due?', 'A stretched chain that cannot be tensioned, or a chain that jumps on the sprocket, needs replacement.', 2),
    (p_bike_chain, 'What chain brands are used?', 'We use quality brands like D.I.D or RK chains suited to your bike model.', 3);

  INSERT INTO plan_service_outcomes (plan_id, title, image_url, description, display_order) VALUES
    (p_bike_chain, 'Smooth Power Delivery', '', 'A new chain and sprocket set eliminates power loss and harsh drive feel.', 1),
    (p_bike_chain, 'Quieter Drivetrain', '', 'No more chain slap or rattling noise from a worn drive set.', 2);

  -- =====================================================
  -- BIKE: Tyre Replacement (Both)
  -- =====================================================
  INSERT INTO plan_features (plan_id, feature, display_order) VALUES
    (p_bike_tyre, 'Both front and rear tyres removed and replaced', 1),
    (p_bike_tyre, 'New inner tubes fitted (if applicable)', 2),
    (p_bike_tyre, 'Wheel balancing after fitting', 3),
    (p_bike_tyre, 'Tyre pressure set to spec', 4),
    (p_bike_tyre, 'Rim and spoke condition check', 5);

  INSERT INTO plan_steps (plan_id, step_description, display_order) VALUES
    (p_bike_tyre, 'Both wheels removed from bike', 1),
    (p_bike_tyre, 'Old tyres dismounted and disposed', 2),
    (p_bike_tyre, 'New tyres and tubes fitted', 3),
    (p_bike_tyre, 'Wheels balanced and pressure set', 4),
    (p_bike_tyre, 'Wheels refitted and rim runout verified', 5),
    (p_bike_tyre, 'Test ride to confirm handling', 6);

  INSERT INTO plan_faqs (plan_id, question, answer, display_order) VALUES
    (p_bike_tyre, 'What tyre brands are available?', 'We stock MRF, CEAT, Metzeler, and Michelin across different price points.', 1),
    (p_bike_tyre, 'When should tyres be replaced?', 'When tread depth reaches the wear indicators, or when you notice cracking or bulging.', 2),
    (p_bike_tyre, 'Can I choose tubeless?', 'Yes, tubeless fitment is available for compatible rims.', 3);

  INSERT INTO plan_service_outcomes (plan_id, title, image_url, description, display_order) VALUES
    (p_bike_tyre, 'Confident Grip in All Conditions', '', 'New tyres deliver full traction on wet and dry roads.', 1),
    (p_bike_tyre, 'Stable, Predictable Handling', '', 'Fresh rubber with correct pressure significantly improves cornering stability.', 2);

  -- =====================================================
  -- BIKE: Brake Pads Replacement
  -- =====================================================
  INSERT INTO plan_features (plan_id, feature, display_order) VALUES
    (p_bike_brake, 'Front and rear brake pad measurement', 1),
    (p_bike_brake, 'Worn pads replaced with quality parts', 2),
    (p_bike_brake, 'Brake disc/drum condition check', 3),
    (p_bike_brake, 'Brake fluid level topped up', 4);

  INSERT INTO plan_steps (plan_id, step_description, display_order) VALUES
    (p_bike_brake, 'Brake caliper or drum cover opened', 1),
    (p_bike_brake, 'Pad thickness measured front and rear', 2),
    (p_bike_brake, 'Worn pads removed and replaced', 3),
    (p_bike_brake, 'Disc or drum surface inspected', 4),
    (p_bike_brake, 'Brake fluid topped up and system bled if needed', 5),
    (p_bike_brake, 'Test braking before handover', 6);

  INSERT INTO plan_faqs (plan_id, question, answer, display_order) VALUES
    (p_bike_brake, 'How do I know pads need replacing?', 'Squealing sounds, reduced braking feel, or vibration under braking are warning signs.', 1),
    (p_bike_brake, 'Are both front and rear pads replaced?', 'We measure both and replace only worn pads; you approve before replacement.', 2);

  INSERT INTO plan_service_outcomes (plan_id, title, image_url, description, display_order) VALUES
    (p_bike_brake, 'Full Braking Power Restored', '', 'New pads give confident, predictable stopping performance.', 1),
    (p_bike_brake, 'Silent, Squeal-Free Braking', '', 'Eliminate the annoying squeal of worn brake pads.', 2);

  -- =====================================================
  -- BIKE: Carburetor Cleaning & Tuning
  -- =====================================================
  INSERT INTO plan_features (plan_id, feature, display_order) VALUES
    (p_bike_carb, 'Carburetor removed and fully disassembled', 1),
    (p_bike_carb, 'All jets, needles, and passages cleaned', 2),
    (p_bike_carb, 'Float level and needle position set', 3),
    (p_bike_carb, 'Idle mixture and speed tuned', 4),
    (p_bike_carb, 'Airbox and filter checked', 5);

  INSERT INTO plan_steps (plan_id, step_description, display_order) VALUES
    (p_bike_carb, 'Fuel tap closed and fuel line disconnected', 1),
    (p_bike_carb, 'Carburetor removed and stripped down', 2),
    (p_bike_carb, 'All components cleaned in ultrasonic or carb cleaner', 3),
    (p_bike_carb, 'Jets inspected for blockage and cleared', 4),
    (p_bike_carb, 'Float height and needle clip position set', 5),
    (p_bike_carb, 'Carb reassembled and refitted', 6),
    (p_bike_carb, 'Idle speed and mixture fine-tuned running', 7);

  INSERT INTO plan_faqs (plan_id, question, answer, display_order) VALUES
    (p_bike_carb, 'How do I know if my carb needs cleaning?', 'Hard starting, rough idle, poor throttle response, or black smoke are classic signs.', 1),
    (p_bike_carb, 'How long does carb cleaning take?', 'About 1 hour including reassembly and tuning.', 2),
    (p_bike_carb, 'Does this apply to fuel-injected bikes?', 'No, this service is for carbureted bikes. Fuel injected bikes require throttle body cleaning.', 3);

  INSERT INTO plan_service_outcomes (plan_id, title, image_url, description, display_order) VALUES
    (p_bike_carb, 'Crisp Throttle Response', '', 'A clean carburetor eliminates hesitation and delivers smooth acceleration from idle.', 1),
    (p_bike_carb, 'Better Fuel Economy', '', 'Correct air-fuel mixture reduces fuel wastage and improves mileage.', 2);

  -- =====================================================
  -- BIKE: Suspension Service
  -- =====================================================
  INSERT INTO plan_features (plan_id, feature, display_order) VALUES
    (p_bike_suspension, 'Front fork oil change', 1),
    (p_bike_suspension, 'Fork seal inspection and replacement if leaking', 2),
    (p_bike_suspension, 'Rear shock absorber condition check', 3),
    (p_bike_suspension, 'Linkage and pivot bearing lubrication', 4);

  INSERT INTO plan_steps (plan_id, step_description, display_order) VALUES
    (p_bike_suspension, 'Front forks removed from bike', 1),
    (p_bike_suspension, 'Fork seals inspected and replaced if leaking', 2),
    (p_bike_suspension, 'Old fork oil drained and replaced', 3),
    (p_bike_suspension, 'Forks reassembled and refitted', 4),
    (p_bike_suspension, 'Rear shock stroke and linkage pivot checked', 5),
    (p_bike_suspension, 'Test ride to verify suspension action', 6);

  INSERT INTO plan_faqs (plan_id, question, answer, display_order) VALUES
    (p_bike_suspension, 'How often should fork oil be changed?', 'Every 20,000 km or if the forks feel stiff, spongy, or are leaking oil.', 1),
    (p_bike_suspension, 'Is rear shock replacement included?', 'Rear shock replacement is quoted separately; inspection is included.', 2);

  INSERT INTO plan_service_outcomes (plan_id, title, image_url, description, display_order) VALUES
    (p_bike_suspension, 'Plush, Controlled Ride', '', 'Fresh fork oil and good seals restore the suspension''s ability to absorb bumps effectively.', 1),
    (p_bike_suspension, 'Leak-Free Forks', '', 'New seals prevent oil contamination on the brake disc and tyre.', 2);

  -- =====================================================
  -- BIKE: Engine Diagnostics
  -- =====================================================
  INSERT INTO plan_features (plan_id, feature, display_order) VALUES
    (p_bike_engine_diag, 'OBD / proprietary scanner fault code read', 1),
    (p_bike_engine_diag, 'Live sensor data analysis', 2),
    (p_bike_engine_diag, 'Check engine light investigation', 3),
    (p_bike_engine_diag, 'Diagnostic report with repair priority', 4);

  INSERT INTO plan_steps (plan_id, step_description, display_order) VALUES
    (p_bike_engine_diag, 'Diagnostic tool connected to bike ECU', 1),
    (p_bike_engine_diag, 'All fault codes and freeze frame data retrieved', 2),
    (p_bike_engine_diag, 'Live engine data reviewed at idle', 3),
    (p_bike_engine_diag, 'Fault root cause identified and documented', 4),
    (p_bike_engine_diag, 'Repair recommendations with cost estimates given', 5);

  INSERT INTO plan_faqs (plan_id, question, answer, display_order) VALUES
    (p_bike_engine_diag, 'My bike has no check engine light — can I still benefit?', 'Yes, scans can reveal stored faults that have not triggered the warning light yet.', 1),
    (p_bike_engine_diag, 'Which bikes are supported?', 'All modern fuel-injected bikes with OBD-II or manufacturer diagnostic ports.', 2);

  INSERT INTO plan_service_outcomes (plan_id, title, image_url, description, display_order) VALUES
    (p_bike_engine_diag, 'Clear Health Report', '', 'Know exactly what is happening inside the engine and what needs attention.', 1),
    (p_bike_engine_diag, 'Early Fault Detection', '', 'Catch small issues before they grow into expensive engine damage.', 2);

  -- =====================================================
  -- BIKE: Fuel Injection Cleaning
  -- =====================================================
  INSERT INTO plan_features (plan_id, feature, display_order) VALUES
    (p_bike_fuel_inj, 'Throttle body cleaning', 1),
    (p_bike_fuel_inj, 'Fuel injector flush treatment', 2),
    (p_bike_fuel_inj, 'Idle speed and TPS reset', 3),
    (p_bike_fuel_inj, 'Intake manifold inspection', 4);

  INSERT INTO plan_steps (plan_id, step_description, display_order) VALUES
    (p_bike_fuel_inj, 'Throttle body removed and cleaned with specialist solution', 1),
    (p_bike_fuel_inj, 'Fuel injector flush additive introduced', 2),
    (p_bike_fuel_inj, 'Idle speed and throttle position sensor calibrated', 3),
    (p_bike_fuel_inj, 'Intake tract inspected for leaks', 4),
    (p_bike_fuel_inj, 'Test ride to confirm smooth idle and throttle', 5);

  INSERT INTO plan_faqs (plan_id, question, answer, display_order) VALUES
    (p_bike_fuel_inj, 'How often should FI cleaning be done?', 'Every 15,000 km or when you notice rough idle or loss of mileage.', 1),
    (p_bike_fuel_inj, 'Is this only for FI bikes?', 'Yes, this service is specifically for fuel-injected bikes.', 2);

  INSERT INTO plan_service_outcomes (plan_id, title, image_url, description, display_order) VALUES
    (p_bike_fuel_inj, 'Smooth Idle & Clean Throttle', '', 'Clean injectors and throttle body eliminate rough idle and hesitation.', 1),
    (p_bike_fuel_inj, 'Restored Mileage', '', 'Efficient fuel atomisation improves combustion and fuel economy.', 2);

  -- =====================================================
  -- BIKE: Doorstep Full Service
  -- =====================================================
  INSERT INTO plan_features (plan_id, feature, display_order) VALUES
    (p_bike_doorstep, 'Everything in Comprehensive Full Service', 1),
    (p_bike_doorstep, 'Mechanic arrives at your location', 2),
    (p_bike_doorstep, 'Fully equipped mobile kit', 3),
    (p_bike_doorstep, 'Digital report shared after service', 4);

  INSERT INTO plan_faqs (plan_id, question, answer, display_order) VALUES
    (p_bike_doorstep, 'Do I need to provide any tools or space?', 'No, the mechanic brings all required tools. Just a flat, open area is sufficient.', 1),
    (p_bike_doorstep, 'Is doorstep available on weekends?', 'Yes, doorstep service is available 7 days a week subject to slot availability.', 2),
    (p_bike_doorstep, 'What if additional parts are needed?', 'The mechanic will inform you and source parts nearby or schedule a follow-up.', 3);

  INSERT INTO plan_service_outcomes (plan_id, title, image_url, description, display_order) VALUES
    (p_bike_doorstep, 'Zero Hassle Servicing', '', 'Get your bike fully serviced without leaving your home or office.', 1),
    (p_bike_doorstep, 'Full Transparency', '', 'Watch every step performed live and ask questions in real time.', 2);

  -- =====================================================
  -- CAR: Spark Plug Replacement
  -- =====================================================
  INSERT INTO plan_features (plan_id, feature, display_order) VALUES
    (p_car_spark, 'All spark plugs removed and inspected', 1),
    (p_car_spark, 'New OEM-spec spark plugs fitted', 2),
    (p_car_spark, 'Plug lead / coil pack condition checked', 3),
    (p_car_spark, 'Gap verified before installation', 4);

  INSERT INTO plan_steps (plan_id, step_description, display_order) VALUES
    (p_car_spark, 'Engine cover removed for plug access', 1),
    (p_car_spark, 'Old plugs removed and condition noted', 2),
    (p_car_spark, 'New plugs gapped and torqued to spec', 3),
    (p_car_spark, 'Ignition coils and leads checked', 4),
    (p_car_spark, 'Engine started and idle quality verified', 5);

  INSERT INTO plan_faqs (plan_id, question, answer, display_order) VALUES
    (p_car_spark, 'How often should spark plugs be replaced?', 'Copper plugs every 30,000 km; iridium or platinum every 60,000–100,000 km.', 1),
    (p_car_spark, 'Will I notice a difference after replacement?', 'Yes — smoother idle, better acceleration, and improved fuel economy are common results.', 2);

  INSERT INTO plan_service_outcomes (plan_id, title, image_url, description, display_order) VALUES
    (p_car_spark, 'Stronger Ignition', '', 'New plugs provide a consistent spark for complete combustion.', 1),
    (p_car_spark, 'Better Fuel Economy', '', 'Efficient combustion reduces fuel wastage at every engine cycle.', 2);

  -- =====================================================
  -- CAR: Air Filter Replacement
  -- =====================================================
  INSERT INTO plan_features (plan_id, feature, display_order) VALUES
    (p_car_air_filter, 'Old air filter removed and disposed', 1),
    (p_car_air_filter, 'New OEM-grade air filter fitted', 2),
    (p_car_air_filter, 'Air box inspected for cracks or leaks', 3);

  INSERT INTO plan_steps (plan_id, step_description, display_order) VALUES
    (p_car_air_filter, 'Air box clips released and cover removed', 1),
    (p_car_air_filter, 'Old filter removed and discarded', 2),
    (p_car_air_filter, 'Air box interior wiped clean', 3),
    (p_car_air_filter, 'New filter installed and box secured', 4);

  INSERT INTO plan_faqs (plan_id, question, answer, display_order) VALUES
    (p_car_air_filter, 'How often should air filter be replaced?', 'Every 15,000–20,000 km or annually, or sooner in dusty environments.', 1),
    (p_car_air_filter, 'Can a dirty air filter affect performance?', 'Yes — a clogged filter restricts airflow, reducing power and increasing fuel consumption.', 2);

  INSERT INTO plan_service_outcomes (plan_id, title, image_url, description, display_order) VALUES
    (p_car_air_filter, 'Improved Engine Breathing', '', 'Unrestricted airflow delivers the correct air-fuel mixture for peak combustion.', 1),
    (p_car_air_filter, 'Protected Engine Internals', '', 'A clean filter prevents dust and debris from entering and damaging the engine.', 2);

  -- =====================================================
  -- BIKE: Oil Change
  -- =====================================================
  INSERT INTO plan_features (plan_id, feature, display_order) VALUES
    (p_bike_oil, 'Engine oil fully drained', 1),
    (p_bike_oil, 'Oil filter replaced', 2),
    (p_bike_oil, 'Fresh manufacturer-spec oil filled', 3),
    (p_bike_oil, 'Drain plug torqued and sealed', 4);

  INSERT INTO plan_steps (plan_id, step_description, display_order) VALUES
    (p_bike_oil, 'Drain plug removed and old oil collected', 1),
    (p_bike_oil, 'Oil filter removed and replaced', 2),
    (p_bike_oil, 'Drain plug refitted with new crush washer', 3),
    (p_bike_oil, 'Fresh oil filled to correct level', 4),
    (p_bike_oil, 'Engine started to circulate oil and leak check done', 5);

  INSERT INTO plan_faqs (plan_id, question, answer, display_order) VALUES
    (p_bike_oil, 'What type of oil is used?', 'Manufacturer-recommended 10W-30 or 10W-40 mineral or semi-synthetic oil.', 1),
    (p_bike_oil, 'Is this for all bike types?', 'Yes, we service all two-wheelers including scooters, commuters, and sports bikes.', 2);

  INSERT INTO plan_service_outcomes (plan_id, title, image_url, description, display_order) VALUES
    (p_bike_oil, 'Cooler, Quieter Engine', '', 'Fresh oil with correct viscosity reduces engine heat and mechanical noise.', 1),
    (p_bike_oil, 'Longer Engine Life', '', 'Clean oil prevents wear on cam, piston, and gearbox components.', 2);

  -- =====================================================
  -- BIKE: Spark Plug Replacement
  -- =====================================================
  INSERT INTO plan_features (plan_id, feature, display_order) VALUES
    (p_bike_spark, 'Old spark plug removed and inspected', 1),
    (p_bike_spark, 'New OEM-spec plug gapped and fitted', 2),
    (p_bike_spark, 'Cap and lead condition checked', 3);

  INSERT INTO plan_steps (plan_id, step_description, display_order) VALUES
    (p_bike_spark, 'Plug cap removed and plug extracted', 1),
    (p_bike_spark, 'Plug condition inspected (colour, electrode wear)', 2),
    (p_bike_spark, 'New plug gapped correctly and torqued', 3),
    (p_bike_spark, 'Engine started and idle quality confirmed', 4);

  INSERT INTO plan_faqs (plan_id, question, answer, display_order) VALUES
    (p_bike_spark, 'How often should a bike spark plug be replaced?', 'Every 6,000–10,000 km for standard plugs; iridium plugs last longer.', 1),
    (p_bike_spark, 'Can a worn plug affect starting?', 'Yes, a worn plug causes hard starting, misfires, and poor idle.', 2);

  INSERT INTO plan_service_outcomes (plan_id, title, image_url, description, display_order) VALUES
    (p_bike_spark, 'Easy Starting', '', 'A strong spark ensures reliable cold and hot starting every time.', 1),
    (p_bike_spark, 'Smoother Idle', '', 'Consistent ignition eliminates the rough, uneven idle of a worn plug.', 2);

  -- =====================================================
  -- BIKE: Air Filter Replacement
  -- =====================================================
  INSERT INTO plan_features (plan_id, feature, display_order) VALUES
    (p_bike_air_filter, 'Old air filter removed', 1),
    (p_bike_air_filter, 'New OEM-grade filter installed', 2),
    (p_bike_air_filter, 'Air box cleaned and sealed', 3);

  INSERT INTO plan_steps (plan_id, step_description, display_order) VALUES
    (p_bike_air_filter, 'Seat and side panels removed for filter access', 1),
    (p_bike_air_filter, 'Old filter removed and discarded', 2),
    (p_bike_air_filter, 'Air box wiped clean', 3),
    (p_bike_air_filter, 'New filter fitted and panels reassembled', 4);

  INSERT INTO plan_faqs (plan_id, question, answer, display_order) VALUES
    (p_bike_air_filter, 'How often should a bike air filter be changed?', 'Every 10,000–15,000 km or when visibly dirty.', 1),
    (p_bike_air_filter, 'Is a dirty filter harmful?', 'Yes, restricted airflow causes rich running, poor mileage, and increased emissions.', 2);

  INSERT INTO plan_service_outcomes (plan_id, title, image_url, description, display_order) VALUES
    (p_bike_air_filter, 'Better Throttle & Mileage', '', 'Clean air supply optimises combustion for improved responsiveness and fuel economy.', 1),
    (p_bike_air_filter, 'Engine Protection', '', 'Blocks fine dust particles from reaching engine cylinders.', 2);

  -- =====================================================
  -- BIKE: Battery Replacement
  -- =====================================================
  INSERT INTO plan_features (plan_id, feature, display_order) VALUES
    (p_bike_battery, 'Old battery removed and recycled', 1),
    (p_bike_battery, 'New sealed MF battery fitted', 2),
    (p_bike_battery, 'Charging system health check', 3),
    (p_bike_battery, '12-month warranty on battery', 4);

  INSERT INTO plan_steps (plan_id, step_description, display_order) VALUES
    (p_bike_battery, 'Battery load tested to confirm failure', 1),
    (p_bike_battery, 'Old battery disconnected and removed', 2),
    (p_bike_battery, 'New MF battery installed and terminals secured', 3),
    (p_bike_battery, 'Charging voltage checked with multimeter', 4),
    (p_bike_battery, 'Bike started and electrical systems verified', 5);

  INSERT INTO plan_faqs (plan_id, question, answer, display_order) VALUES
    (p_bike_battery, 'What battery type will be installed?', 'We use sealed maintenance-free (MF) batteries from reputed brands like Exide or Amaron.', 1),
    (p_bike_battery, 'How long do bike batteries last?', '2–3 years on average depending on usage and charging habits.', 2);

  INSERT INTO plan_service_outcomes (plan_id, title, image_url, description, display_order) VALUES
    (p_bike_battery, 'Instant, Reliable Starting', '', 'A new battery cranks the engine confidently in all weather conditions.', 1),
    (p_bike_battery, 'Stable Electrics', '', 'Correct voltage prevents damage to lights, indicators, and the ECU.', 2);

END $$;

-- =========================================================
-- POPULATE TEST DATA (SNAKE CASE SCHEMA)
-- =========================================================

-- Replace 'DRIVER_UUID_HERE' with a real UUID from your drivers table
-- You can find one by running: SELECT id FROM drivers LIMIT 1;

-- 1. Insert Trips (using snake_case columns)
INSERT INTO public.trips 
(
  id, 
  driver_id, 
  driver_name, 
  pickup_location, 
  delivery_location, 
  customer_name, 
  status, 
  total_cost, 
  driver_earnings, 
  company_revenue, 
  delivery_date, 
  estimated_delivery,
  assigned_date
)
VALUES
-- Trip 1: On-time delivery
('trip-101', 'DRIVER_UUID_HERE', 'John Doe', 'Nairobi', 'Mombasa', 'Global Traders', 'delivered', 15000, 10500, 4500, NOW(), NOW() + INTERVAL '1 hour', NOW()),

-- Trip 2: Late delivery
('trip-102', 'DRIVER_UUID_HERE', 'John Doe', 'Kisumu', 'Nakuru', 'Farm Fresh', 'delivered', 12000, 8400, 3600, NOW() + INTERVAL '2 days', NOW() + INTERVAL '1 day', NOW()),

-- Trip 3: Completed trip
('trip-103', 'DRIVER_UUID_HERE', 'John Doe', 'Eldoret', 'Kitale', 'Agro Corp', 'delivered', 8000, 5600, 2400, NOW(), NOW() + INTERVAL '1 day', NOW());

-- 2. Insert Orders (using snake_case columns if trips worked)
INSERT INTO public.orders
(
  id, 
  customer_id, 
  customer_name, 
  pickup_location, 
  delivery_location, 
  status, 
  total_cost, 
  order_date, 
  created_at
)
VALUES
('order-101', 'CUSTOMER_UUID_HERE', 'Global Traders', 'Nairobi', 'Mombasa', 'delivered', 15000, NOW(), NOW()),
('order-102', 'CUSTOMER_UUID_HERE', 'Farm Fresh', 'Kisumu', 'Nakuru', 'delivered', 12000, NOW(), NOW());

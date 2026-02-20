-- Comprehensive Migration: Standardize ALL Tables to snake_case
-- This script aligns the database schema with the Flutter models' toJson/fromJson expectations.

-- ==========================================
-- 1. DRIVERS TABLE
-- ==========================================
ALTER TABLE public.drivers ADD COLUMN IF NOT EXISTS license_number TEXT;
ALTER TABLE public.drivers ADD COLUMN IF NOT EXISTS license_expiry TEXT;
ALTER TABLE public.drivers ADD COLUMN IF NOT EXISTS total_trips INTEGER DEFAULT 0;
ALTER TABLE public.drivers ADD COLUMN IF NOT EXISTS current_location TEXT;
ALTER TABLE public.drivers ADD COLUMN IF NOT EXISTS current_vehicle TEXT;
ALTER TABLE public.drivers ADD COLUMN IF NOT EXISTS join_date TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE public.drivers ADD COLUMN IF NOT EXISTS profile_image TEXT;
ALTER TABLE public.drivers ADD COLUMN IF NOT EXISTS additional_info JSONB;

UPDATE public.drivers SET
    license_number = COALESCE(license_number, "licenseNumber"),
    license_expiry = COALESCE(license_expiry, "licenseExpiry"),
    total_trips = COALESCE(total_trips, "totalTrips"),
    current_location = COALESCE(current_location, "currentLocation"),
    current_vehicle = COALESCE(current_vehicle, "currentVehicle"),
    join_date = COALESCE(join_date, "joinDate"),
    profile_image = COALESCE(profile_image, "profileImage"),
    additional_info = COALESCE(additional_info, "additionalInfo");

-- ==========================================
-- 2. CUSTOMERS TABLE
-- ==========================================
ALTER TABLE public.customers ADD COLUMN IF NOT EXISTS company_name TEXT;
ALTER TABLE public.customers ADD COLUMN IF NOT EXISTS join_date TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE public.customers ADD COLUMN IF NOT EXISTS total_orders INTEGER DEFAULT 0;
ALTER TABLE public.customers ADD COLUMN IF NOT EXISTS total_spent DOUBLE PRECISION DEFAULT 0.0;
ALTER TABLE public.customers ADD COLUMN IF NOT EXISTS profile_image TEXT;
ALTER TABLE public.customers ADD COLUMN IF NOT EXISTS additional_info JSONB;

UPDATE public.customers SET
    company_name = COALESCE(company_name, "companyName"),
    join_date = COALESCE(join_date, "joinDate"),
    total_orders = COALESCE(total_orders, "totalOrders"),
    total_spent = COALESCE(total_spent, "totalSpent"),
    profile_image = COALESCE(profile_image, "profileImage"),
    additional_info = COALESCE(additional_info, "additionalInfo");

-- ==========================================
-- 3. ORDERS TABLE
-- ==========================================
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS customer_id UUID REFERENCES public.profiles(id);
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS customer_name TEXT;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS pickup_location TEXT;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS delivery_location TEXT;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS order_date TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS pickup_date TIMESTAMP WITH TIME ZONE;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS delivery_date TIMESTAMP WITH TIME ZONE;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS estimated_delivery TIMESTAMP WITH TIME ZONE;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS driver_id UUID REFERENCES public.profiles(id);
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS driver_name TEXT;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS vehicle_plate TEXT;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS cargo_type TEXT;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS cargo_weight DOUBLE PRECISION;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS special_instructions TEXT;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS total_cost DOUBLE PRECISION DEFAULT 0.0;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS tracking_number TEXT;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS additional_info JSONB;

UPDATE public.orders SET
    customer_id = COALESCE(customer_id, "customerId"),
    customer_name = COALESCE(customer_name, "customerName"),
    pickup_location = COALESCE(pickup_location, "pickupLocation"),
    delivery_location = COALESCE(delivery_location, "deliveryLocation"),
    order_date = COALESCE(order_date, "orderDate"),
    pickup_date = COALESCE(pickup_date, "pickupDate"),
    delivery_date = COALESCE(delivery_date, "deliveryDate"),
    estimated_delivery = COALESCE(estimated_delivery, "estimatedDelivery"),
    driver_id = COALESCE(driver_id, "driverId"),
    driver_name = COALESCE(driver_name, "driverName"),
    vehicle_plate = COALESCE(vehicle_plate, "vehiclePlate"),
    cargo_type = COALESCE(cargo_type, "cargoType"),
    cargo_weight = COALESCE(cargo_weight, "cargoWeight"),
    special_instructions = COALESCE(special_instructions, "specialInstructions"),
    total_cost = COALESCE(total_cost, "totalCost"),
    tracking_number = COALESCE(tracking_number, "trackingNumber"),
    additional_info = COALESCE(additional_info, "additionalInfo");

-- ==========================================
-- 4. VEHICLES TABLE
-- ==========================================
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS registration_number TEXT;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS assigned_driver_id UUID REFERENCES public.profiles(id);
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS assigned_driver_name TEXT;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS fuel_capacity DOUBLE PRECISION;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS current_fuel_level DOUBLE PRECISION;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS purchase_date TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS last_maintenance_date TIMESTAMP WITH TIME ZONE;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS next_maintenance_date TIMESTAMP WITH TIME ZONE;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS current_location TEXT;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS load_capacity DOUBLE PRECISION;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS insurance_expiry TEXT;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS license_expiry TEXT;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS purchase_price DOUBLE PRECISION;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS current_value DOUBLE PRECISION;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS additional_info JSONB;

UPDATE public.vehicles SET
    registration_number = COALESCE(registration_number, "registrationNumber"),
    assigned_driver_id = COALESCE(assigned_driver_id, "assignedDriverId"),
    assigned_driver_name = COALESCE(assigned_driver_name, "assignedDriverName"),
    fuel_capacity = COALESCE(fuel_capacity, "fuelCapacity"),
    current_fuel_level = COALESCE(current_fuel_level, "currentFuelLevel"),
    purchase_date = COALESCE(purchase_date, "purchaseDate"),
    last_maintenance_date = COALESCE(last_maintenance_date, "lastMaintenanceDate"),
    next_maintenance_date = COALESCE(next_maintenance_date, "nextMaintenanceDate"),
    current_location = COALESCE(current_location, "currentLocation"),
    load_capacity = COALESCE(load_capacity, "loadCapacity"),
    insurance_expiry = COALESCE(insurance_expiry, "insuranceExpiry"),
    license_expiry = COALESCE(license_expiry, "licenseExpiry"),
    purchase_price = COALESCE(purchase_price, "purchasePrice"),
    current_value = COALESCE(current_value, "currentValue"),
    additional_info = COALESCE(additional_info, "additionalInfo");

-- ==========================================
-- 5. UPDATE RLS POLICIES
-- ==========================================

-- Trips
DROP POLICY IF EXISTS "Drivers view own trips" ON public.trips;
CREATE POLICY "Drivers view own trips" ON public.trips FOR SELECT 
USING (auth.uid() = driver_id OR auth.uid() = "driverId");

-- Orders
DROP POLICY IF EXISTS "Customers view own orders" ON public.orders;
CREATE POLICY "Customers view own orders" ON public.orders FOR SELECT 
USING (auth.uid() = customer_id OR auth.uid() = "customerId");

DROP POLICY IF EXISTS "Customers can insert their own orders" ON public.orders;
CREATE POLICY "Customers can insert their own orders" ON public.orders FOR INSERT 
WITH CHECK (auth.uid() = customer_id OR auth.uid() = "customerId");

-- Profiles
DROP POLICY IF EXISTS "Users can update own profile." ON public.profiles;
CREATE POLICY "Users can update own profile." ON public.profiles FOR UPDATE 
USING (auth.uid() = id);

-- ==========================================
-- 6. RELOAD SCHEMA NOTIFICATION
-- ==========================================
NOTIFY pgrst, 'reload schema';

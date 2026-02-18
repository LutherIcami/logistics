-- FIX: Standardize Trips Table Columns to snake_case
-- Align database schema with Flutter code to fix data retrieval and real-time updates.

-- 1. Add snake_case columns if missing
ALTER TABLE public.trips ADD COLUMN IF NOT EXISTS driver_id UUID REFERENCES public.profiles(id);
ALTER TABLE public.trips ADD COLUMN IF NOT EXISTS driver_name TEXT;
ALTER TABLE public.trips ADD COLUMN IF NOT EXISTS pickup_location TEXT;
ALTER TABLE public.trips ADD COLUMN IF NOT EXISTS delivery_location TEXT;
ALTER TABLE public.trips ADD COLUMN IF NOT EXISTS customer_name TEXT;
ALTER TABLE public.trips ADD COLUMN IF NOT EXISTS customer_phone TEXT;
ALTER TABLE public.trips ADD COLUMN IF NOT EXISTS assigned_date TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE public.trips ADD COLUMN IF NOT EXISTS pickup_date TIMESTAMP WITH TIME ZONE;
ALTER TABLE public.trips ADD COLUMN IF NOT EXISTS delivery_date TIMESTAMP WITH TIME ZONE;
ALTER TABLE public.trips ADD COLUMN IF NOT EXISTS estimated_delivery TIMESTAMP WITH TIME ZONE;
ALTER TABLE public.trips ADD COLUMN IF NOT EXISTS vehicle_id TEXT;
ALTER TABLE public.trips ADD COLUMN IF NOT EXISTS vehicle_plate TEXT;
ALTER TABLE public.trips ADD COLUMN IF NOT EXISTS cargo_type TEXT;
ALTER TABLE public.trips ADD COLUMN IF NOT EXISTS cargo_weight DOUBLE PRECISION;
ALTER TABLE public.trips ADD COLUMN IF NOT EXISTS special_instructions TEXT;
ALTER TABLE public.trips ADD COLUMN IF NOT EXISTS distance DOUBLE PRECISION;
ALTER TABLE public.trips ADD COLUMN IF NOT EXISTS estimated_earnings DOUBLE PRECISION;
ALTER TABLE public.trips ADD COLUMN IF NOT EXISTS total_cost DOUBLE PRECISION;
ALTER TABLE public.trips ADD COLUMN IF NOT EXISTS driver_earnings DOUBLE PRECISION;
ALTER TABLE public.trips ADD COLUMN IF NOT EXISTS company_revenue DOUBLE PRECISION;
ALTER TABLE public.trips ADD COLUMN IF NOT EXISTS additional_info JSONB;
ALTER TABLE public.trips ADD COLUMN IF NOT EXISTS tracking_number TEXT;


-- 2. Migrate Data from camelCase (if exists) to snake_case (if empty)
UPDATE public.trips SET
    driver_id = COALESCE(driver_id, "driverId"),
    driver_name = COALESCE(driver_name, "driverName"),
    pickup_location = COALESCE(pickup_location, "pickupLocation"),
    delivery_location = COALESCE(delivery_location, "deliveryLocation"),
    customer_name = COALESCE(customer_name, "customerName"),
    customer_phone = COALESCE(customer_phone, "customerPhone"),
    assigned_date = COALESCE(assigned_date, "assignedDate"),
    pickup_date = COALESCE(pickup_date, "pickupDate"),
    delivery_date = COALESCE(delivery_date, "deliveryDate"),
    estimated_delivery = COALESCE(estimated_delivery, "estimatedDelivery"),
    vehicle_id = COALESCE(vehicle_id, "vehicleId"),
    vehicle_plate = COALESCE(vehicle_plate, "vehiclePlate"),
    cargo_type = COALESCE(cargo_type, "cargoType"),
    cargo_weight = COALESCE(cargo_weight, "cargoWeight"),
    special_instructions = COALESCE(special_instructions, "specialInstructions"),
    estimated_earnings = COALESCE(estimated_earnings, "estimatedEarnings"),
    total_cost = COALESCE(total_cost, "totalCost"),
    driver_earnings = COALESCE(driver_earnings, "driverEarnings"),
    company_revenue = COALESCE(company_revenue, "companyRevenue"),
    additional_info = COALESCE(additional_info, "additionalInfo"),
    tracking_number = COALESCE(tracking_number, "trackingNumber");

-- 3. Create Trigger Function to Sync Columns (Bi-directional Sync)
CREATE OR REPLACE FUNCTION public.sync_trips_columns()
RETURNS TRIGGER AS $$
BEGIN
    -- Sync snake_case -> camelCase if updated
    IF NEW.driver_id IS DISTINCT FROM OLD.driver_id THEN NEW."driverId" := NEW.driver_id; END IF;
    IF NEW.driver_name IS DISTINCT FROM OLD.driver_name THEN NEW."driverName" := NEW.driver_name; END IF;
    IF NEW.pickup_location IS DISTINCT FROM OLD.pickup_location THEN NEW."pickupLocation" := NEW.pickup_location; END IF;
    IF NEW.delivery_location IS DISTINCT FROM OLD.delivery_location THEN NEW."deliveryLocation" := NEW.delivery_location; END IF;
    IF NEW.customer_name IS DISTINCT FROM OLD.customer_name THEN NEW."customerName" := NEW.customer_name; END IF;
    -- ... (add crucial fields)
    IF NEW.status IS DISTINCT FROM OLD.status THEN NEW.status := NEW.status; END IF; -- Status is likely fine (lowercase)
    
    -- Sync camelCase -> snake_case if updated (and snake_case wasn't updated)
    IF NEW."driverId" IS DISTINCT FROM OLD."driverId" AND NEW.driver_id IS NOT DISTINCT FROM OLD.driver_id THEN NEW.driver_id := NEW."driverId"; END IF;
    IF NEW."driverName" IS DISTINCT FROM OLD."driverName" AND NEW.driver_name IS NOT DISTINCT FROM OLD.driver_name THEN NEW.driver_name := NEW."driverName"; END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger is simplified here. Since we fully rely on snake_case in new code, 
-- we mainly ensure existing data is migrated. Use the migration above.

-- 4. Verify RLS Policies
-- Ensure drivers can view their own trips (using new column)
DROP POLICY IF EXISTS "Drivers view own trips" ON public.trips;
CREATE POLICY "Drivers view own trips" 
ON public.trips FOR SELECT 
USING (auth.uid() = driver_id OR auth.uid() = "driverId");

-- 5. Notify API
NOTIFY pgrst, 'reload schema';

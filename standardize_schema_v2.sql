-- STANDARDIZE DATABASE SCHEMA TO SNAKE_CASE
-- This script renames columns in orders and trips to use snake_case
-- and adds missing columns for tracking synchronization.

-- 1. FIX ORDERS TABLE
DO $$ 
BEGIN
    -- Rename columns if they exist as camelCase
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'customerId') THEN
        ALTER TABLE public.orders RENAME COLUMN "customerId" TO customer_id;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'customerName') THEN
        ALTER TABLE public.orders RENAME COLUMN "customerName" TO customer_name;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'pickupLocation') THEN
        ALTER TABLE public.orders RENAME COLUMN "pickupLocation" TO pickup_location;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'deliveryLocation') THEN
        ALTER TABLE public.orders RENAME COLUMN "deliveryLocation" TO delivery_location;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'orderDate') THEN
        ALTER TABLE public.orders RENAME COLUMN "orderDate" TO order_date;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'pickupDate') THEN
        ALTER TABLE public.orders RENAME COLUMN "pickupDate" TO pickup_date;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'deliveryDate') THEN
        ALTER TABLE public.orders RENAME COLUMN "deliveryDate" TO delivery_date;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'estimatedDelivery') THEN
        ALTER TABLE public.orders RENAME COLUMN "estimatedDelivery" TO estimated_delivery;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'driverId') THEN
        ALTER TABLE public.orders RENAME COLUMN "driverId" TO driver_id;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'driverName') THEN
        ALTER TABLE public.orders RENAME COLUMN "driverName" TO driver_name;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'vehiclePlate') THEN
        ALTER TABLE public.orders RENAME COLUMN "vehiclePlate" TO vehicle_plate;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'cargoType') THEN
        ALTER TABLE public.orders RENAME COLUMN "cargoType" TO cargo_type;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'cargoWeight') THEN
        ALTER TABLE public.orders RENAME COLUMN "cargoWeight" TO cargo_weight;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'specialInstructions') THEN
        ALTER TABLE public.orders RENAME COLUMN "specialInstructions" TO special_instructions;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'totalCost') THEN
        ALTER TABLE public.orders RENAME COLUMN "totalCost" TO total_cost;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'trackingNumber') THEN
        ALTER TABLE public.orders RENAME COLUMN "trackingNumber" TO tracking_number;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'additionalInfo') THEN
        ALTER TABLE public.orders RENAME COLUMN "additionalInfo" TO additional_info;
    END IF;
END $$;

-- 2. FIX TRIPS TABLE
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'trips' AND column_name = 'driverId') THEN
        ALTER TABLE public.trips RENAME COLUMN "driverId" TO driver_id;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'trips' AND column_name = 'driverName') THEN
        ALTER TABLE public.trips RENAME COLUMN "driverName" TO driver_name;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'trips' AND column_name = 'pickupLocation') THEN
        ALTER TABLE public.trips RENAME COLUMN "pickupLocation" TO pickup_location;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'trips' AND column_name = 'deliveryLocation') THEN
        ALTER TABLE public.trips RENAME COLUMN "deliveryLocation" TO delivery_location;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'trips' AND column_name = 'customerName') THEN
        ALTER TABLE public.trips RENAME COLUMN "customerName" TO customer_name;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'trips' AND column_name = 'customerPhone') THEN
        ALTER TABLE public.trips RENAME COLUMN "customerPhone" TO customer_phone;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'trips' AND column_name = 'assignedDate') THEN
        ALTER TABLE public.trips RENAME COLUMN "assignedDate" TO assigned_date;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'trips' AND column_name = 'pickupDate') THEN
        ALTER TABLE public.trips RENAME COLUMN "pickupDate" TO pickup_date;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'trips' AND column_name = 'deliveryDate') THEN
        ALTER TABLE public.trips RENAME COLUMN "deliveryDate" TO delivery_date;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'trips' AND column_name = 'estimatedDelivery') THEN
        ALTER TABLE public.trips RENAME COLUMN "estimatedDelivery" TO estimated_delivery;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'trips' AND column_name = 'vehicleId') THEN
        ALTER TABLE public.trips RENAME COLUMN "vehicleId" TO vehicle_id;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'trips' AND column_name = 'vehiclePlate') THEN
        ALTER TABLE public.trips RENAME COLUMN "vehiclePlate" TO vehicle_plate;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'trips' AND column_name = 'cargoType') THEN
        ALTER TABLE public.trips RENAME COLUMN "cargoType" TO cargo_type;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'trips' AND column_name = 'cargoWeight') THEN
        ALTER TABLE public.trips RENAME COLUMN "cargoWeight" TO cargo_weight;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'trips' AND column_name = 'specialInstructions') THEN
        ALTER TABLE public.trips RENAME COLUMN "specialInstructions" TO special_instructions;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'trips' AND column_name = 'estimatedEarnings') THEN
        ALTER TABLE public.trips RENAME COLUMN "estimatedEarnings" TO estimated_earnings;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'trips' AND column_name = 'additionalInfo') THEN
        ALTER TABLE public.trips RENAME COLUMN "additionalInfo" TO additional_info;
    END IF;

    -- ADD tracking_number to trips if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'trips' AND column_name = 'tracking_number') THEN
        ALTER TABLE public.trips ADD COLUMN tracking_number TEXT;
    END IF;
END $$;

-- 3. UPDATED SYNC TRIGGER
CREATE OR REPLACE FUNCTION public.sync_trip_status_to_orders()
RETURNS TRIGGER AS $$
BEGIN
    -- Update orders table using snake_case columns
    UPDATE public.orders
    SET 
        status = NEW.status,
        pickup_date = NEW.pickup_date,
        delivery_date = NEW.delivery_date,
        driver_id = NEW.driver_id,
        driver_name = NEW.driver_name,
        vehicle_plate = NEW.vehicle_plate
    WHERE tracking_number = NEW.tracking_number;
    
    -- Fallback: Match by ID if tracking_number is null
    IF NEW.tracking_number IS NULL THEN
        UPDATE public.orders
        SET 
            status = NEW.status,
            pickup_date = NEW.pickup_date,
            delivery_date = NEW.delivery_date,
            driver_id = NEW.driver_id,
            driver_name = NEW.driver_name,
            vehicle_plate = NEW.vehicle_plate
        WHERE id = NEW.id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recreate trigger
DROP TRIGGER IF EXISTS trigger_sync_trip_orders ON public.trips;
CREATE TRIGGER trigger_sync_trip_orders
AFTER UPDATE ON public.trips
FOR EACH ROW
EXECUTE FUNCTION sync_trip_status_to_orders();

-- 4. ENABLE REALTIME
ALTER PUBLICATION supabase_realtime ADD TABLE orders;
ALTER PUBLICATION supabase_realtime ADD TABLE trips;

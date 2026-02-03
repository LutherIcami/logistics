-- FINAL SCHEMA & POLICY FIX FOR ORDERS AND TRIPS
-- This script: 
-- 1. Standardizes everything to snake_case
-- 2. Grants Admins full manage permissions on Orders
-- 3. Fixes synchronisation triggers

-- 1. STANDARDISING ORDERS TABLE
DO $$ 
BEGIN
    -- Rename columns if they still exist as camelCase (quoted)
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

-- 2. STANDARDISING TRIPS TABLE
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
END $$;

-- 3. FIXING RLS POLICIES FOR ORDERS
-- Ensure Admins can actually UPDATE orders (This was likely the main issue)
DROP POLICY IF EXISTS "Admins view all orders" ON public.orders;
DROP POLICY IF EXISTS "Admins can manage all orders" ON public.orders;

CREATE POLICY "Admins can manage all orders"
ON public.orders FOR ALL 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

-- Also ensure Customers can still see their own
DROP POLICY IF EXISTS "Customers view own orders" ON public.orders;
CREATE POLICY "Customers view own orders" 
ON public.orders FOR SELECT 
USING (auth.uid() = customer_id);

-- 4. FIXING RLS POLICIES FOR TRIPS
DROP POLICY IF EXISTS "Admins can manage all trips" ON public.trips;
CREATE POLICY "Admins can manage all trips"
ON public.trips FOR ALL 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

-- 5. REFRESH REALTIME
ALTER PUBLICATION supabase_realtime ADD TABLE public.orders;
ALTER PUBLICATION supabase_realtime ADD TABLE public.trips;

NOTIFY pgrst, 'reload config';

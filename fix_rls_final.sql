-- FIX RLS POLICIES FOR ORDERS AND TRIPS
-- Allows customers to confirm their own deliveries and drivers to update their trips.

-- 1. FIX ORDERS TABLE POLICIES
DROP POLICY IF EXISTS "Customers view own orders" ON public.orders;
DROP POLICY IF EXISTS "Admins view all orders" ON public.orders;
DROP POLICY IF EXISTS "Customers can insert their own orders" ON public.orders;
DROP POLICY IF EXISTS "Customers can update own orders" ON public.orders;

-- Admin Policy
CREATE POLICY "Admins can manage all orders" ON public.orders 
FOR ALL USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
);

-- Customer Policies
CREATE POLICY "Customers can view own orders" ON public.orders 
FOR SELECT USING (auth.uid() = customer_id);

CREATE POLICY "Customers can insert own orders" ON public.orders 
FOR INSERT WITH CHECK (auth.uid() = customer_id);

CREATE POLICY "Customers can update own orders" ON public.orders 
FOR UPDATE USING (auth.uid() = customer_id);


-- 2. FIX TRIPS TABLE POLICIES
DROP POLICY IF EXISTS "Drivers view own trips" ON public.trips;
DROP POLICY IF EXISTS "Admins view all trips" ON public.trips;
DROP POLICY IF EXISTS "Drivers can view and update own assigned trips" ON public.trips;

-- Admin Policy
CREATE POLICY "Admins can manage all trips" ON public.trips 
FOR ALL USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
);

-- Driver Policy
CREATE POLICY "Drivers can manage own trips" ON public.trips 
FOR ALL USING (auth.uid() = driver_id);

-- 3. FIX SYNC TRIGGER FOR NULL TRACKING NUMBER
-- If tracking_number is missing, we match by ID
CREATE OR REPLACE FUNCTION public.sync_trip_status_to_orders()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.orders
    SET 
        status = NEW.status,
        pickup_date = NEW.pickup_date,
        delivery_date = NEW.delivery_date,
        driver_id = NEW.driver_id,
        driver_name = NEW.driver_name,
        vehicle_plate = NEW.vehicle_plate
    WHERE (tracking_number IS NOT NULL AND tracking_number = NEW.tracking_number)
       OR (id = NEW.id);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

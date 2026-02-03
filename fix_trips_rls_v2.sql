-- FIX TRIPS RLS POLICIES TO USE SNAKE_CASE COLUMNS

-- 1. Drop old policies that might reference "driverId"
DROP POLICY IF EXISTS "Drivers view own trips" ON public.trips;
DROP POLICY IF EXISTS "Drivers can update own trips" ON public.trips;

-- 2. Recreate policies using "driver_id"
CREATE POLICY "Drivers view own trips" 
ON public.trips FOR SELECT 
USING (auth.uid() = driver_id);

CREATE POLICY "Drivers can update own trips" 
ON public.trips FOR UPDATE 
USING (auth.uid() = driver_id);

-- 3. Ensure "admin" policies are safe too
-- (Admins usually check profile role, so they don't depend on trip columns directly, which is fine)

NOTIFY pgrst, 'reload config';

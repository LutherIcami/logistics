-- Fix RLS Policies and Triggers
-- This script ensures admins can manage everything and users can see their own data.

-- 1. Ensure Profiles can be managed by Admins
CREATE POLICY \
Admins
can
manage
all
profiles\ ON public.profiles FOR ALL USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
);

-- 2. Ensure Drivers table has correct policies
DROP POLICY IF EXISTS \Drivers
viewable
by
authenticated\ ON public.drivers;
DROP POLICY IF EXISTS \Update
own
driver
profile\ ON public.drivers;

CREATE POLICY \Admins
can
manage
all
drivers\ ON public.drivers FOR ALL USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
);
CREATE POLICY \Drivers
can
view
own
record\ ON public.drivers FOR SELECT USING (auth.uid() = id);
CREATE POLICY \Drivers
can
update
own
record\ ON public.drivers FOR UPDATE USING (auth.uid() = id);

-- 3. Ensure Trips table has correct policies
DROP POLICY IF EXISTS \Drivers
view
own
trips\ ON public.trips;
DROP POLICY IF EXISTS \Admins
view
all
trips\ ON public.trips;

CREATE POLICY \Admins
can
manage
all
trips\ ON public.trips FOR ALL USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
);
CREATE POLICY \Drivers
can
view
and
update
own
assigned
trips\ ON public.trips FOR ALL USING (auth.uid() = \driverId\);

-- 4. Ensure Vehicles table has correct policies
DROP POLICY IF EXISTS \Vehicles
viewable
by
authenticated\ ON public.vehicles;

CREATE POLICY \Admins
can
manage
all
vehicles\ ON public.vehicles FOR ALL USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
);
CREATE POLICY \Authenticated
users
can
view
vehicles\ ON public.vehicles FOR SELECT USING (auth.role() = 'authenticated');

-- 5. Fix the Driver ID mismatch potential in the handle_new_user trigger
-- Ensure users created with 'driver' role in metadata are handled correctly.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS \$\$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, role)
  VALUES (
    new.id, 
    new.email, 
    COALESCE(new.raw_user_meta_data->>'full_name', ''), 
    COALESCE(new.raw_user_meta_data->>'role', 'customer')
  )
  ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    role = EXCLUDED.role;
  RETURN NEW;
END;
\$\$ LANGUAGE plpgsql SECURITY DEFINER;


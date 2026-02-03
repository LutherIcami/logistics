-- REPAIR KIT: Fix Vehicles Table Structure and Permissions
-- Run this entire script in Supabase SQL Editor

-- 1. Ensure 'images' column exists (and all other optional columns)
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS images TEXT[] DEFAULT '{}'::text[];
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS "fuelCapacity" DOUBLE PRECISION DEFAULT 0.0;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS "currentFuelLevel" DOUBLE PRECISION DEFAULT 0.0;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS "mileage" DOUBLE PRECISION DEFAULT 0.0;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS "purchasePrice" DOUBLE PRECISION;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS "currentValue" DOUBLE PRECISION;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS "insuranceExpiry" TEXT;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS "licenseExpiry" TEXT;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS "currentLocation" TEXT;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS "assignedDriverId" UUID;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS "assignedDriverName" TEXT;

-- 2. Setup Storage Bucket for Images
INSERT INTO storage.buckets (id, name, public) 
VALUES ('vehicle-images', 'vehicle-images', true)
ON CONFLICT (id) DO NOTHING;

-- 3. RESET Vehicle Policies (Delete old ones and create fresh)
DROP POLICY IF EXISTS "Vehicles viewable by authenticated" ON public.vehicles;
DROP POLICY IF EXISTS "Admins can insert vehicles" ON public.vehicles;
DROP POLICY IF EXISTS "Admins can update vehicles" ON public.vehicles;
DROP POLICY IF EXISTS "Admins can delete vehicles" ON public.vehicles;

-- 4. Create "Open" Policies for Admins
CREATE POLICY "Vehicles viewable by authenticated" 
ON public.vehicles FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Admins can insert vehicles" 
ON public.vehicles FOR INSERT 
WITH CHECK (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can update vehicles" 
ON public.vehicles FOR UPDATE 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can delete vehicles" 
ON public.vehicles FOR DELETE 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

-- 5. Fix Storage Policies
DROP POLICY IF EXISTS "Allow authenticated uploads" ON storage.objects;
DROP POLICY IF EXISTS "Allow public viewing" ON storage.objects;

CREATE POLICY "Allow authenticated uploads" ON storage.objects
FOR INSERT TO authenticated WITH CHECK (bucket_id = 'vehicle-images');

CREATE POLICY "Allow public viewing" ON storage.objects
FOR SELECT TO public USING (bucket_id = 'vehicle-images');

-- 6. Emergency Admin Fix (Ensures you are an admin)
UPDATE public.profiles SET role = 'admin' WHERE id = auth.uid();

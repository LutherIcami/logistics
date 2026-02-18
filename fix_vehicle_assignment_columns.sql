-- FIX: Standardize Vehicle-Driver Assignment Columns to snake_case
-- Run this script in the Supabase SQL Editor

-- 1. Ensure snake_case columns exist (Best Practice for Postgres/Supabase)
ALTER TABLE public.vehicles 
ADD COLUMN IF NOT EXISTS assigned_driver_id UUID REFERENCES public.profiles(id);

ALTER TABLE public.vehicles 
ADD COLUMN IF NOT EXISTS assigned_driver_name TEXT;

-- 2. Migrate data from camelCase columns if they exist (and snake_case is empty)
DO $$
BEGIN
    -- Migrate ID
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'vehicles' AND column_name = 'assignedDriverId') THEN
        UPDATE public.vehicles 
        SET assigned_driver_id = "assignedDriverId" 
        WHERE assigned_driver_id IS NULL AND "assignedDriverId" IS NOT NULL;
    END IF;

    -- Migrate Name
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'vehicles' AND column_name = 'assignedDriverName') THEN
        UPDATE public.vehicles 
        SET assigned_driver_name = "assignedDriverName" 
        WHERE assigned_driver_name IS NULL AND "assignedDriverName" IS NOT NULL;
    END IF;
END $$;

-- 3. Update Permissions (RLS) to allow Admins to modify these columns
-- (Existing generic update policy should cover it, but we verify)

DROP POLICY IF EXISTS "Admins can update vehicles" ON public.vehicles;

CREATE POLICY "Admins can update vehicles" 
ON public.vehicles FOR UPDATE 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

-- 4. Reload Schema Cache to Ensure API sees new columns
NOTIFY pgrst, 'reload schema';

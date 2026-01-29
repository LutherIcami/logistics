-- Add images column to vehicles table
ALTER TABLE public.vehicles 
ADD COLUMN IF NOT EXISTS images TEXT[] DEFAULT '{}'::text[];

-- Update RLS policies to ensure images are accessible (if needed, usually covered by table policy)
-- The existing "Vehicles viewable by authenticated" policy covers all columns.

-- Create system_settings table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.system_settings (
    id SERIAL PRIMARY KEY,
    "baseOrderRate" DOUBLE PRECISION DEFAULT 2000.0,
    "distanceRate" DOUBLE PRECISION DEFAULT 25.0,
    "weightRate" DOUBLE PRECISION DEFAULT 0.5,
    "driverCommissionRate" DOUBLE PRECISION DEFAULT 0.7,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default settings row if not exists
INSERT INTO public.system_settings (id, "baseOrderRate", "distanceRate", "weightRate", "driverCommissionRate")
VALUES (1, 2000.0, 25.0, 0.5, 0.7)
ON CONFLICT (id) DO NOTHING;

-- Add commission and revenue tracking to system (column already in CREATE TABLE, but this ensures it exists if table existed)
ALTER TABLE public.system_settings 
ADD COLUMN IF NOT EXISTS "driverCommissionRate" DOUBLE PRECISION DEFAULT 0.7; -- Default 70% to driver

-- Update trips table with revenue breakdown
ALTER TABLE public.trips 
ADD COLUMN IF NOT EXISTS "total_cost" DOUBLE PRECISION DEFAULT 0.0,
ADD COLUMN IF NOT EXISTS "driver_earnings" DOUBLE PRECISION DEFAULT 0.0,
ADD COLUMN IF NOT EXISTS "company_revenue" DOUBLE PRECISION DEFAULT 0.0;

-- Function to calculate trip financials
CREATE OR REPLACE FUNCTION public.calculate_trip_financials()
RETURNS TRIGGER AS $$
DECLARE
    settings RECORD;
    v_base_rate DOUBLE PRECISION;
    v_distance_rate DOUBLE PRECISION;
    v_weight_rate DOUBLE PRECISION;
    v_comm_rate DOUBLE PRECISION;
    v_total DOUBLE PRECISION;
BEGIN
    -- Get current settings from id=1
    SELECT * INTO settings FROM public.system_settings WHERE id = 1;
    
    -- Fallback to defaults if settings row is missing
    IF settings IS NULL THEN
        v_base_rate := 2000.0;
        v_distance_rate := 25.0;
        v_weight_rate := 0.5;
        v_comm_rate := 0.7;
    ELSE
        v_base_rate := COALESCE(settings."baseOrderRate", 2000.0);
        v_distance_rate := COALESCE(settings."distanceRate", 25.0);
        v_weight_rate := COALESCE(settings."weightRate", 0.5);
        v_comm_rate := COALESCE(settings."driverCommissionRate", 0.7);
    END IF;

    -- Formula: Base + (Distance * DistanceRate) + (Weight * WeightRate)
    v_total := v_base_rate + 
               (COALESCE(NEW.distance, 0) * v_distance_rate) + 
               (COALESCE(NEW.cargo_weight, 0) * v_weight_rate);
    
    NEW.total_cost := v_total;
    NEW.driver_earnings := v_total * v_comm_rate;
    NEW.company_revenue := v_total * (1 - v_comm_rate);
    NEW.estimated_earnings := NEW.driver_earnings; -- Keep legacy field in sync

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-calculate on insert or distance/weight update
DROP TRIGGER IF EXISTS trigger_calculate_trip_financials ON public.trips;
CREATE TRIGGER trigger_calculate_trip_financials
BEFORE INSERT OR UPDATE OF distance, cargo_weight ON public.trips
FOR EACH ROW EXECUTE FUNCTION public.calculate_trip_financials();

-- Update existing trips to populate the new columns
UPDATE public.trips SET distance = distance; 

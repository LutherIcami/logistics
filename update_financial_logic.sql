-- Add commission and revenue tracking to system
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
    -- Get current settings
    SELECT * INTO settings FROM public.system_settings WHERE id = 1;
    
    v_base_rate := COALESCE(settings."baseOrderRate", 2000.0);
    v_distance_rate := COALESCE(settings."distanceRate", 25.0);
    v_weight_rate := COALESCE(settings."weightRate", 0.5);
    v_comm_rate := COALESCE(settings."driverCommissionRate", 0.7);

    -- Formula: Base + (Distance * DistanceRate) + (Weight * WeightRate)
    v_total := v_base_rate + 
               (COALESCE(NEW.distance, 0) * v_distance_rate) + 
               (COALESCE(NEW."cargoWeight", 0) * v_weight_rate);
    
    NEW.total_cost := v_total;
    NEW.driver_earnings := v_total * v_comm_rate;
    NEW.company_revenue := v_total * (1 - v_comm_rate);
    NEW."estimatedEarnings" := NEW.driver_earnings; -- Keep legacy field in sync

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-calculate on insert or distance/weight update
DROP TRIGGER IF EXISTS trigger_calculate_trip_financials ON public.trips;
CREATE TRIGGER trigger_calculate_trip_financials
BEFORE INSERT OR UPDATE OF distance, "cargoWeight" ON public.trips
FOR EACH ROW EXECUTE FUNCTION public.calculate_trip_financials();

-- Update existing trips to populate the new columns
UPDATE public.trips SET distance = distance; 

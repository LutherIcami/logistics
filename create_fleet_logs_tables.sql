-- Create Fuel Logs Table
CREATE TABLE IF NOT EXISTS public.fuel_logs (
    id TEXT PRIMARY KEY,
    vehicle_id TEXT REFERENCES public.vehicles(id) ON DELETE CASCADE,
    vehicle_registration TEXT NOT NULL,
    driver_id UUID REFERENCES public.profiles(id),
    driver_name TEXT NOT NULL,
    date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    odometer DOUBLE PRECISION NOT NULL,
    liters DOUBLE PRECISION NOT NULL,
    total_cost DOUBLE PRECISION NOT NULL,
    station_name TEXT,
    receipt_image TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create Maintenance Logs Table
CREATE TABLE IF NOT EXISTS public.maintenance_logs (
    id TEXT PRIMARY KEY,
    vehicle_id TEXT REFERENCES public.vehicles(id) ON DELETE CASCADE,
    vehicle_registration TEXT NOT NULL,
    driver_id UUID REFERENCES public.profiles(id),
    driver_name TEXT NOT NULL,
    date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    odometer DOUBLE PRECISION NOT NULL,
    type TEXT NOT NULL, -- routine, repair, tires, oilChange, insurance, inspection, other
    description TEXT NOT NULL,
    total_cost DOUBLE PRECISION NOT NULL,
    service_provider TEXT,
    receipt_image TEXT,
    next_service_odometer DOUBLE PRECISION,
    next_service_date TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.fuel_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.maintenance_logs ENABLE ROW LEVEL SECURITY;

-- Policies for Admins
CREATE POLICY "Admins manage fuel logs" ON public.fuel_logs 
    FOR ALL USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins manage maintenance logs" ON public.maintenance_logs 
    FOR ALL USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

-- Policies for Drivers (Optional: View their own logs)
CREATE POLICY "Drivers view own fuel logs" ON public.fuel_logs 
    FOR SELECT USING (auth.uid() = driver_id);

CREATE POLICY "Drivers view own maintenance logs" ON public.maintenance_logs 
    FOR SELECT USING (auth.uid() = driver_id);

-- Realtime
ALTER TABLE public.fuel_logs REPLICA IDENTITY FULL;
ALTER TABLE public.maintenance_logs REPLICA IDENTITY FULL;

-- Re-enable realtime for these tables
BEGIN;
  DROP PUBLICATION IF EXISTS supabase_realtime;
  CREATE PUBLICATION supabase_realtime FOR TABLE fuel_logs, maintenance_logs;
COMMIT;

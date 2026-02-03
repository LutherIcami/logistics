-- STANDARDIZE DRIVERS TABLE AND ADD STATS TRIGGER
-- This script ensures the drivers table follows snake_case and auto-updates trip counts.

-- 1. STANDARDIZE DRIVERS COLUMNS
DO $$ 
BEGIN
    if exists (select 1 from information_schema.columns where table_name = 'drivers' and column_name = 'licenseNumber') then
        ALTER TABLE public.drivers RENAME COLUMN "licenseNumber" TO license_number;
    end if;
    if exists (select 1 from information_schema.columns where table_name = 'drivers' and column_name = 'licenseExpiry') then
        ALTER TABLE public.drivers RENAME COLUMN "licenseExpiry" TO license_expiry;
    end if;
    if exists (select 1 from information_schema.columns where table_name = 'drivers' and column_name = 'totalTrips') then
        ALTER TABLE public.drivers RENAME COLUMN "totalTrips" TO total_trips;
    end if;
    if exists (select 1 from information_schema.columns where table_name = 'drivers' and column_name = 'currentLocation') then
        ALTER TABLE public.drivers RENAME COLUMN "currentLocation" TO current_location;
    end if;
    if exists (select 1 from information_schema.columns where table_name = 'drivers' and column_name = 'currentVehicle') then
        ALTER TABLE public.drivers RENAME COLUMN "currentVehicle" TO current_vehicle;
    end if;
    if exists (select 1 from information_schema.columns where table_name = 'drivers' and column_name = 'joinDate') then
        ALTER TABLE public.drivers RENAME COLUMN "joinDate" TO join_date;
    end if;
    if exists (select 1 from information_schema.columns where table_name = 'drivers' and column_name = 'profileImage') then
        ALTER TABLE public.drivers RENAME COLUMN "profileImage" TO profile_image;
    end if;
    if exists (select 1 from information_schema.columns where table_name = 'drivers' and column_name = 'additionalInfo') then
        ALTER TABLE public.drivers RENAME COLUMN "additionalInfo" TO additional_info;
    end if;
END $$;

-- 2. CREATE FUNCTION TO UPDATE DRIVER STATS
CREATE OR REPLACE FUNCTION public.update_driver_stats()
RETURNS TRIGGER AS $$
BEGIN
    -- Increment count when a trip is marked 'delivered'
    IF (NEW.status = 'delivered' AND (OLD.status IS NULL OR OLD.status != 'delivered')) THEN
        UPDATE public.drivers
        SET total_trips = total_trips + 1
        WHERE id = NEW.driver_id;
    END IF;
    
    -- Decrement count if a 'delivered' status is reversed (rare, but for safety)
    IF (OLD.status = 'delivered' AND (NEW.status IS NULL OR NEW.status != 'delivered')) THEN
        UPDATE public.drivers
        SET total_trips = GREATEST(0, total_trips - 1)
        WHERE id = NEW.driver_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. ATTACH TRIGGER TO TRIPS TABLE
DROP TRIGGER IF EXISTS trigger_update_driver_stats ON public.trips;
CREATE TRIGGER trigger_update_driver_stats
AFTER UPDATE ON public.trips
FOR EACH ROW
EXECUTE FUNCTION public.update_driver_stats();

-- 4. INITIAL SYNC (Update counts for existing delivered trips)
UPDATE public.drivers d
SET total_trips = (
    SELECT count(*) 
    FROM public.trips t 
    WHERE t.driver_id = d.id AND t.status = 'delivered'
);

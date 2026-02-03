-- v4: SYNC TRIP STATUS TO ORDERS (Reliable One-to-One Sync)
-- This script ensures that when a driver starts a trip (status -> in_transit),
-- the corresponding Order also moves to 'in_transit' automatically.

CREATE OR REPLACE FUNCTION public.sync_trip_status_to_orders()
RETURNS TRIGGER AS $$
BEGIN
    -- 1. Try to sync by tracking_number first
    UPDATE public.orders
    SET 
        status = NEW.status,
        pickup_date = NEW.pickup_date,
        delivery_date = NEW.delivery_date
    WHERE tracking_number = NEW.tracking_number 
    AND tracking_number IS NOT NULL;
    
    -- 2. Fallback: Sync by ID (since we now ensure Trip ID == Order ID)
    IF NOT FOUND THEN
        UPDATE public.orders
        SET 
            status = NEW.status,
            pickup_date = NEW.pickup_date,
            delivery_date = NEW.delivery_date
        WHERE id = NEW.id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RECREATE TRIGGER
DROP TRIGGER IF EXISTS trigger_sync_trip_orders ON public.trips;
CREATE TRIGGER trigger_sync_trip_orders
AFTER UPDATE ON public.trips
FOR EACH ROW
EXECUTE FUNCTION sync_trip_status_to_orders();

-- Ensure realtime is enabled for both (no error if already member)
DO $$ 
BEGIN
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.orders;
    EXCEPTION WHEN others THEN END;
    
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.trips;
    EXCEPTION WHEN others THEN END;
END $$;

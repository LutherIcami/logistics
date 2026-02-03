-- FUNCTION: SYNC TRIP STATUS TO ORDERS (v2 - specific for camelCase orders table)
-- Fixes issue where trigger failed because orders table uses camelCase columns (e.g. "trackingNumber")
-- while trips table uses snake_case (e.g. tracking_number).

CREATE OR REPLACE FUNCTION sync_trip_status_to_orders()
RETURNS TRIGGER AS $$
BEGIN
    -- Update orders table using quoted identifiers for camelCase columns
    UPDATE public.orders
    SET 
        "status" = NEW.status,
        "pickupDate" = NEW.pickup_date,
        "deliveryDate" = NEW.delivery_date,
        "driverId" = NEW.driver_id
    WHERE "trackingNumber" = NEW.tracking_number;
    
    -- Fallback: Match by ID if tracking_number is null
    IF NEW.tracking_number IS NULL THEN
        UPDATE public.orders
        SET 
            "status" = NEW.status,
            "pickupDate" = NEW.pickup_date,
            "deliveryDate" = NEW.delivery_date,
            "driverId" = NEW.driver_id
        WHERE "id" = NEW.id;
    END IF;

    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        -- If columns don't exist, ignore (or you could log it)
        -- This prevents the driver app from crashing if orders table schema is different
        RAISE NOTICE 'Sync trigger failed: %', SQLERRM;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RECREATE TRIGGER
DROP TRIGGER IF EXISTS trigger_sync_trip_orders ON public.trips;

CREATE TRIGGER trigger_sync_trip_orders
AFTER UPDATE ON public.trips
FOR EACH ROW
EXECUTE FUNCTION sync_trip_status_to_orders();

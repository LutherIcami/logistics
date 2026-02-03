-- BIDIRECTIONAL SYNC BETWEEN ORDERS AND TRIPS
-- This script ensures that cancellations from the customer's side propagate to the driver's side.

-- 1. FUNCTION TO SYNC ORDER STATUS TO TRIPS
CREATE OR REPLACE FUNCTION public.sync_order_status_to_trips()
RETURNS TRIGGER AS $$
BEGIN
    -- Only sync if status has changed
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        -- If an order is cancelled, cancel the corresponding trip
        IF NEW.status = 'cancelled' THEN
            UPDATE public.trips
            SET status = 'cancelled'
            WHERE tracking_number = NEW.tracking_number;
        END IF;

        -- If an order is marked as delivered (maybe by admin), update the trip
        IF NEW.status = 'delivered' THEN
            UPDATE public.trips
            SET 
                status = 'delivered',
                delivery_date = COALESCE(NEW.delivery_date, now())
            WHERE tracking_number = NEW.tracking_number AND status != 'delivered';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. CREATE TRIGGER ON ORDERS
DROP TRIGGER IF EXISTS trigger_sync_order_to_trips ON public.orders;
CREATE TRIGGER trigger_sync_order_to_trips
AFTER UPDATE ON public.orders
FOR EACH ROW
EXECUTE FUNCTION sync_order_status_to_trips();

-- 3. ENSURE TRIP TO ORDER SYNC IS COMPLETE
-- We already have sync_trip_status_to_orders, let's make sure it handles 'assigned' status correctly
CREATE OR REPLACE FUNCTION public.sync_trip_status_to_orders()
RETURNS TRIGGER AS $$
BEGIN
    -- Update orders table using snake_case columns
    UPDATE public.orders
    SET 
        status = NEW.status,
        pickup_date = NEW.pickup_date,
        delivery_date = NEW.delivery_date,
        driver_id = NEW.driver_id,
        driver_name = NEW.driver_name,
        vehicle_plate = NEW.vehicle_plate
    WHERE tracking_number = NEW.tracking_number;
    
    -- Fallback: Match by ID if tracking_number is null (for backward compatibility)
    IF NEW.tracking_number IS NULL THEN
        UPDATE public.orders
        SET 
            status = NEW.status
        WHERE id = NEW.id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

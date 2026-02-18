-- Check and fix RLS policies for driver performance queries

-- First, let's ensure the get_driver_performance_stats function runs with proper permissions
-- Functions need to bypass RLS or we need proper policies

-- Option 1: Make the function SECURITY DEFINER so it runs with creator's permissions
CREATE OR REPLACE FUNCTION get_driver_performance_stats()
RETURNS TABLE (
    driver_id TEXT,
    driver_name TEXT,
    trips_completed BIGINT,
    rating DOUBLE PRECISION,
    earnings DOUBLE PRECISION,
    on_time_rate DOUBLE PRECISION,
    safety_incidents INT
) 
SECURITY DEFINER  -- This makes the function run with the permissions of the function creator
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.id::TEXT as driver_id,
        COALESCE(d.name, 'Unknown Driver') as driver_name,
        COALESCE(COUNT(CASE WHEN t.status = 'delivered' THEN 1 END), 0) as trips_completed,
        COALESCE(d.rating, 0.0)::DOUBLE PRECISION as rating,
        COALESCE(SUM(CASE 
            WHEN t.status = 'delivered' THEN 
                COALESCE(t.driver_earnings, t."estimatedEarnings", 0) 
            ELSE 0 
        END), 0.0)::DOUBLE PRECISION as earnings,
        -- Calculate on-time rate
        CASE 
            WHEN COUNT(CASE WHEN t.status = 'delivered' THEN 1 END) > 0 THEN
                COALESCE(
                    (COUNT(CASE 
                        WHEN t.status = 'delivered' 
                        AND t."deliveryDate" IS NOT NULL 
                        AND t."estimatedDelivery" IS NOT NULL 
                        AND t."deliveryDate" <= t."estimatedDelivery" 
                        THEN 1 
                    END)::DOUBLE PRECISION / NULLIF(COUNT(CASE WHEN t.status = 'delivered' THEN 1 END), 0)),
                    0.0
                )
            ELSE 1.0
        END as on_time_rate,
        0 as safety_incidents
    FROM drivers d
    LEFT JOIN trips t ON d.id = t."driverId"
    WHERE d.status IS NULL OR d.status = 'active' OR d.status = 'on_leave'
    GROUP BY d.id, d.name, d.rating
    ORDER BY trips_completed DESC, rating DESC;
END;
$$ LANGUAGE plpgsql;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_driver_performance_stats() TO authenticated;
GRANT EXECUTE ON FUNCTION get_driver_performance_stats() TO anon;

-- Also grant execute on the debug function
GRANT EXECUTE ON FUNCTION debug_drivers() TO authenticated;
GRANT EXECUTE ON FUNCTION debug_drivers() TO anon;

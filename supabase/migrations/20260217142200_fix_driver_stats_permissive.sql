-- Ultra-permissive version of the driver performance function
-- This version removes strict status filtering to ensure ALL drivers are returned

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
SECURITY DEFINER -- Ensures RLS is bypassed
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.id::TEXT as driver_id,
        COALESCE(d.name, 'Unknown Driver') as driver_name,
        -- Count only delivered trips for completed count
        COALESCE(COUNT(CASE WHEN t.status = 'delivered' THEN 1 END), 0) as trips_completed,
        -- Default rating to 0 if null
        COALESCE(d.rating, 0.0)::DOUBLE PRECISION as rating,
        -- Calculate earnings
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
            ELSE 1.0 -- Default to 100% on-time if no trips (neutral)
        END as on_time_rate,
        0 as safety_incidents
    FROM drivers d
    LEFT JOIN trips t ON d.id = t."driverId"
    -- UPDATED: Removed restrictive status filtering. Now shows ALL drivers.
    GROUP BY d.id, d.name, d.rating
    ORDER BY trips_completed DESC, rating DESC;
END;
$$ LANGUAGE plpgsql;

-- Grant permissions again to be absolutely sure
GRANT EXECUTE ON FUNCTION get_driver_performance_stats() TO authenticated;
GRANT EXECUTE ON FUNCTION get_driver_performance_stats() TO anon;
GRANT EXECUTE ON FUNCTION get_driver_performance_stats() TO service_role;

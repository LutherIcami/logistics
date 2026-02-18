-- Comprehensive driver performance function that handles all edge cases
-- This version will return drivers even if they have no trips at all

CREATE OR REPLACE FUNCTION get_driver_performance_stats()
RETURNS TABLE (
    driver_id TEXT,
    driver_name TEXT,
    trips_completed BIGINT,
    rating DOUBLE PRECISION,
    earnings DOUBLE PRECISION,
    on_time_rate DOUBLE PRECISION,
    safety_incidents INT
) AS $$
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

-- Also create a simpler debug function to see what's in the drivers table
CREATE OR REPLACE FUNCTION debug_drivers()
RETURNS TABLE (
    driver_id TEXT,
    driver_name TEXT,
    driver_email TEXT,
    driver_status TEXT,
    driver_rating DOUBLE PRECISION
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.id::TEXT,
        d.name,
        d.email,
        COALESCE(d.status, 'no_status'),
        COALESCE(d.rating, 0.0)
    FROM drivers d;
END;
$$ LANGUAGE plpgsql;

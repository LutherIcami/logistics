-- Alternative version: Show ALL drivers, even those without completed trips
-- This ensures the admin can see all drivers in the system

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
        d.name as driver_name,
        COUNT(CASE WHEN t.status = 'delivered' THEN 1 END) as trips_completed,
        COALESCE(d.rating, 0)::DOUBLE PRECISION as rating,
        COALESCE(SUM(CASE WHEN t.status = 'delivered' THEN COALESCE(t.driver_earnings, t."estimatedEarnings", 0) ELSE 0 END), 0)::DOUBLE PRECISION as earnings,
        -- Calculate on-time rate: delivered trips where delivery_date <= estimated_delivery
        CASE 
            WHEN COUNT(CASE WHEN t.status = 'delivered' THEN 1 END) > 0 THEN
                (COUNT(CASE 
                    WHEN t.status = 'delivered' 
                    AND t."deliveryDate" IS NOT NULL 
                    AND t."estimatedDelivery" IS NOT NULL 
                    AND t."deliveryDate" <= t."estimatedDelivery" 
                    THEN 1 
                END)::DOUBLE PRECISION / COUNT(CASE WHEN t.status = 'delivered' THEN 1 END))
            ELSE 1.0
        END as on_time_rate,
        0 as safety_incidents
    FROM drivers d
    LEFT JOIN trips t ON d.id = t."driverId"
    WHERE d.status = 'active' OR d.status IS NULL  -- Only show active drivers
    GROUP BY d.id, d.name, d.rating
    ORDER BY trips_completed DESC, rating DESC;
END;
$$ LANGUAGE plpgsql;

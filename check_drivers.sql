-- Check if there are drivers in the database
SELECT COUNT(*) as driver_count FROM drivers;

-- Check driver details
SELECT id, name, email, status, rating, "totalTrips" FROM drivers LIMIT 10;

-- Check trips
SELECT COUNT(*) as trip_count FROM trips;

-- Check trips with driver info
SELECT 
    t.id,
    t."driverId",
    t."driverName",
    t.status,
    t.driver_earnings,
    t."estimatedEarnings"
FROM trips t
LIMIT 10;

-- Test the driver performance function directly
SELECT * FROM get_driver_performance_stats();

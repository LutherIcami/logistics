-- Debug script to inspect drivers and trips data
-- Run this to see what actual values are in the tables

-- 1. List all drivers with their IDs and status
SELECT id, name, status FROM drivers;

-- 2. List all trips with their driverIDs
SELECT id, "driverId", status FROM trips;

-- 3. Check for matching IDs (Inner Join) - to see if ANY trips match drivers
SELECT d.name, t.id as trip_id
FROM drivers d
JOIN trips t ON d.id = t."driverId";

-- 4. Check for mismatches (drivers with no trips)
SELECT d.name, d.id
FROM drivers d
LEFT JOIN trips t ON d.id = t."driverId"
WHERE t.id IS NULL;

-- 5. Check if RLS is hiding data (if you run this as postgres/service_role it shows all)
-- Use the debug function to see if it works
SELECT * FROM get_driver_performance_stats();

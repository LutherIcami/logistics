-- Check column names to confirm if they are snake_case (e.g. driver_id) or camelCase (e.g. driverId)
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'trips'
ORDER BY column_name;

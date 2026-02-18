-- Check columns in trips table
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'trips';

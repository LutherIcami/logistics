# Fix Database Permissions Issue

## Problem
You're getting "Failed to add vehicle" error because the database Row Level Security (RLS) policies are missing INSERT, UPDATE, and DELETE permissions for admin users.

## Root Cause
The current database setup only has SELECT (read) policies for most tables. Admins need full CRUD permissions.

## Solution
Run the SQL migration file to add the missing policies.

### Steps to Fix:

1. **Open Supabase Dashboard**
   - Go to https://supabase.com/dashboard
   - Select your project

2. **Navigate to SQL Editor**
   - Click on "SQL Editor" in the left sidebar

3. **Run the Migration**
   - Open the file: `fix_vehicle_policies.sql`
   - Copy the entire contents
   - Paste into the SQL Editor
   - Click "Run" button

4. **Verify the Fix**
   - Go back to your Flutter app
   - Try adding a vehicle again
   - It should now work successfully!

## What This Migration Does:

✅ **Vehicles**: Adds INSERT, UPDATE, DELETE permissions for admins
✅ **Drivers**: Adds INSERT, UPDATE, DELETE permissions for admins  
✅ **Customers**: Adds INSERT, UPDATE, DELETE permissions for admins
✅ **Invoices**: Adds INSERT, UPDATE, DELETE permissions for admins
✅ **Financial Transactions**: Adds INSERT, UPDATE, DELETE permissions for admins
✅ **Trips/Shipments**: Adds INSERT, UPDATE, DELETE permissions for admins

## Permissions Summary:

| Table | Admins | Drivers | Customers |
|-------|--------|---------|-----------|
| Vehicles | Full CRUD | Read only | Read only |
| Drivers | Full CRUD | Update own | Read only |
| Customers | Full CRUD | Read only | View own |
| Trips | Full CRUD | View/Update own | N/A |
| Invoices | Full CRUD | N/A | View own |
| Transactions | Full CRUD | N/A | N/A |

## Alternative: Using Supabase CLI

If you have Supabase CLI installed:

```bash
supabase db push --file fix_vehicle_policies.sql
```

## Troubleshooting

If you still get errors after running the migration:

1. **Check your user role**:
   ```sql
   SELECT role FROM public.profiles WHERE id = auth.uid();
   ```
   Make sure it returns 'admin'

2. **Verify policies were created**:
   ```sql
   SELECT * FROM pg_policies WHERE tablename = 'vehicles';
   ```

3. **Check for error details** in the Flutter app console

## Need Help?

If the issue persists, check the actual error message in the Flutter console. It will show the specific Supabase error.

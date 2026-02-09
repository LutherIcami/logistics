-- Add missing columns to orders and trips tables for cancellation and financial tracking
DO $$ 
BEGIN
    -- 1. FIX ORDERS TABLE
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'cancellation_reason') THEN
        ALTER TABLE public.orders ADD COLUMN cancellation_reason TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'company_commission') THEN
        ALTER TABLE public.orders ADD COLUMN company_commission DOUBLE PRECISION DEFAULT 0.0;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'driver_payout') THEN
        ALTER TABLE public.orders ADD COLUMN driver_payout DOUBLE PRECISION DEFAULT 0.0;
    END IF;

    -- 2. FIX TRIPS TABLE
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'trips' AND column_name = 'driver_earnings') THEN
        ALTER TABLE public.trips ADD COLUMN driver_earnings DOUBLE PRECISION DEFAULT 0.0;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'trips' AND column_name = 'company_revenue') THEN
        ALTER TABLE public.trips ADD COLUMN company_revenue DOUBLE PRECISION DEFAULT 0.0;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'trips' AND column_name = 'total_cost') THEN
        ALTER TABLE public.trips ADD COLUMN total_cost DOUBLE PRECISION DEFAULT 0.0;
    END IF;

END $$;

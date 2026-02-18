-- ==========================================
-- FIX FINANCIAL DASHBOARD DATA FETCHING
-- Run this entire script in Supabase SQL Editor
-- ==========================================

-- 1. DROP EXISTING FUNCTIONS (To ensure clean slate)
DROP FUNCTION IF EXISTS get_weekly_revenue();
DROP FUNCTION IF EXISTS get_monthly_performance();
DROP FUNCTION IF EXISTS get_revenue_breakdown();
DROP FUNCTION IF EXISTS get_top_customers();

-- 2. CREATE WEEKLY REVENUE FUNCTION
-- Shows company sum of orders for the last 60 days
CREATE OR REPLACE FUNCTION get_weekly_revenue()
RETURNS TABLE (day TEXT, amount DECIMAL) 
SECURITY DEFINER -- Bypass RLS
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        to_char(date_trunc('day', COALESCE("orderDate", created_at, NOW())), 'Dy') as day,
        SUM(COALESCE("totalCost", 0))::DECIMAL as amount
    FROM orders
    WHERE (status NOT IN ('cancelled', 'failed') OR status IS NULL)
      AND COALESCE("orderDate", created_at, NOW()) >= NOW() - INTERVAL '60 days'
    GROUP BY date_trunc('day', COALESCE("orderDate", created_at, NOW()))
    ORDER BY date_trunc('day', COALESCE("orderDate", created_at, NOW()));
END;
$$ LANGUAGE plpgsql;

-- 3. CREATE MONTHLY PERFORMANCE FUNCTION
-- Compares Company Revenue vs Driver Payouts for last 12 months
CREATE OR REPLACE FUNCTION get_monthly_performance()
RETURNS TABLE (month TEXT, revenue DECIMAL, expenses DECIMAL) 
SECURITY DEFINER -- Bypass RLS
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    WITH monthly_data AS (
        SELECT
            date_trunc('month', COALESCE(t."assignedDate", t.created_at, NOW())) as m_date,
            -- Revenue: Company's share (use company_revenue column or fallback to calculation)
            SUM(COALESCE(t.company_revenue, t.total_cost * 0.3, t."estimatedEarnings" * 0.42, 0))::DECIMAL as m_revenue,
            -- Expenses: Driver's share (use driver_earnings column or fallback)
            SUM(COALESCE(t.driver_earnings, t.total_cost * 0.7, t."estimatedEarnings", 0))::DECIMAL as m_expenses
        FROM trips t
        WHERE (t.status NOT IN ('cancelled', 'failed') OR t.status IS NULL)
          AND COALESCE(t."assignedDate", t.created_at, NOW()) >= NOW() - INTERVAL '12 months'
        GROUP BY 1
    )
    SELECT
        to_char(m_date, 'Mon') as month,
        COALESCE(m_revenue, 0) as revenue,
        COALESCE(m_expenses, 0) as expenses
    FROM monthly_data
    ORDER BY m_date;
END;
$$ LANGUAGE plpgsql;

-- 4. CREATE REVENUE BREAKDOWN FUNCTION (Pie Chart)
CREATE OR REPLACE FUNCTION get_revenue_breakdown()
RETURNS TABLE (
    total_revenue DECIMAL,
    company_revenue DECIMAL,
    driver_earnings DECIMAL,
    company_percentage DECIMAL
) 
SECURITY DEFINER -- Bypass RLS
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT
        SUM(COALESCE(t.total_cost, 0))::DECIMAL as total_revenue,
        SUM(COALESCE(t.company_revenue, t.total_cost * 0.3, 0))::DECIMAL as company_revenue,
        SUM(COALESCE(t.driver_earnings, t.total_cost * 0.7, 0))::DECIMAL as driver_earnings,
        CASE 
            WHEN SUM(COALESCE(t.total_cost, 0)) > 0 THEN
                (SUM(COALESCE(t.company_revenue, t.total_cost * 0.3, 0)) / SUM(COALESCE(t.total_cost, 0)) * 100)::DECIMAL
            ELSE 30.0
        END as company_percentage
    FROM trips t
    WHERE t.status NOT IN ('cancelled', 'failed');
END;
$$ LANGUAGE plpgsql;

-- 5. CREATE TOP CUSTOMERS FUNCTION
CREATE OR REPLACE FUNCTION get_top_customers()
RETURNS TABLE (
    customer_id TEXT,
    customer_name TEXT,
    total_spent DECIMAL,
    orders_count BIGINT
) 
SECURITY DEFINER -- Bypass RLS
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id::TEXT,
        COALESCE(c.name, 'Unknown Customer'),
        COALESCE(SUM(o."totalCost"), 0)::DECIMAL as total_spent,
        COUNT(o.id)::BIGINT as orders_count
    FROM customers c
    LEFT JOIN orders o ON c.id = o."customerId"
    GROUP BY c.id, c.name
    HAVING COUNT(o.id) > 0
    ORDER BY total_spent DESC
    LIMIT 5;
END;
$$ LANGUAGE plpgsql;

-- 6. GRANT PERMISSIONS (Essential for API access)
GRANT EXECUTE ON FUNCTION get_weekly_revenue() TO authenticated, anon, service_role;
GRANT EXECUTE ON FUNCTION get_monthly_performance() TO authenticated, anon, service_role;
GRANT EXECUTE ON FUNCTION get_revenue_breakdown() TO authenticated, anon, service_role;
GRANT EXECUTE ON FUNCTION get_top_customers() TO authenticated, anon, service_role;

-- 7. REFRESH DRIVER STATS PERMISSIONS TOO (Just in case)
GRANT EXECUTE ON FUNCTION get_driver_performance_stats() TO authenticated, anon, service_role;

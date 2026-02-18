-- Fix Financial Reporting Functions with Robust Logic and Type Safety

-- Drop existing functions to avoid signature mismatch issues
DROP FUNCTION IF EXISTS get_weekly_revenue();
DROP FUNCTION IF EXISTS get_monthly_performance();
DROP FUNCTION IF EXISTS get_revenue_breakdown();
DROP FUNCTION IF EXISTS get_top_customers();

-- 1. Weekly Revenue (Company Revenue)
CREATE OR REPLACE FUNCTION get_weekly_revenue()
RETURNS TABLE (day TEXT, amount DECIMAL) 
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        to_char(date_trunc('day', COALESCE("orderDate", created_at, NOW())), 'Dy') as day,
        SUM(COALESCE("totalCost", 0))::DECIMAL as amount
    FROM orders
    WHERE (status IN ('delivered', 'confirmed', 'completed') OR status IS NULL)
      AND COALESCE("orderDate", created_at, NOW()) >= NOW() - INTERVAL '60 days' -- Extended
    GROUP BY date_trunc('day', COALESCE("orderDate", created_at, NOW()))
    ORDER BY date_trunc('day', COALESCE("orderDate", created_at, NOW()));
END;
$$ LANGUAGE plpgsql;

-- 2. Monthly Performance (Company Revenue vs Driver Payouts)
CREATE OR REPLACE FUNCTION get_monthly_performance()
RETURNS TABLE (month TEXT, revenue DECIMAL, expenses DECIMAL) 
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    WITH monthly_data AS (
        SELECT
            date_trunc('month', COALESCE(t."assignedDate", t.created_at, NOW())) as m_date,
            -- Revenue: Company's share
            SUM(COALESCE(t.company_revenue, t."estimatedEarnings" * 0.42, 0))::DECIMAL as m_revenue,
            -- Expenses: Driver's share
            SUM(COALESCE(t.driver_earnings, t."estimatedEarnings", 0))::DECIMAL as m_expenses
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

-- 3. Revenue Breakdown (Pie Chart)
CREATE OR REPLACE FUNCTION get_revenue_breakdown()
RETURNS TABLE (
    total_revenue DECIMAL,
    company_revenue DECIMAL,
    driver_earnings DECIMAL,
    company_percentage DECIMAL
) 
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT
        SUM(COALESCE(t.total_cost, t."estimatedEarnings" * 1.42, 0))::DECIMAL as total_revenue,
        SUM(COALESCE(t.company_revenue, t."estimatedEarnings" * 0.42, 0))::DECIMAL as company_revenue,
        SUM(COALESCE(t.driver_earnings, t."estimatedEarnings", 0))::DECIMAL as driver_earnings,
        CASE 
            WHEN SUM(COALESCE(t.total_cost, 0)) > 0 THEN
                (SUM(COALESCE(t.company_revenue, 0)) / SUM(COALESCE(t.total_cost, 0)) * 100)::DECIMAL
            ELSE 30.0
        END as company_percentage
    FROM trips t
    WHERE t.status NOT IN ('cancelled', 'failed');
END;
$$ LANGUAGE plpgsql;

-- 4. Top Customers
-- Simplified to generic type matching
CREATE OR REPLACE FUNCTION get_top_customers()
RETURNS TABLE (
    customer_id TEXT,
    customer_name TEXT,
    total_spent DECIMAL,
    orders_count BIGINT
) 
SECURITY DEFINER
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
    LIMIT 10;
END;
$$ LANGUAGE plpgsql;

-- Grant permissions again to be safe
GRANT EXECUTE ON FUNCTION get_weekly_revenue() TO authenticated;
GRANT EXECUTE ON FUNCTION get_weekly_revenue() TO anon;
GRANT EXECUTE ON FUNCTION get_monthly_performance() TO authenticated;
GRANT EXECUTE ON FUNCTION get_monthly_performance() TO anon;
GRANT EXECUTE ON FUNCTION get_revenue_breakdown() TO authenticated;
GRANT EXECUTE ON FUNCTION get_revenue_breakdown() TO anon;
GRANT EXECUTE ON FUNCTION get_top_customers() TO authenticated;
GRANT EXECUTE ON FUNCTION get_top_customers() TO anon;

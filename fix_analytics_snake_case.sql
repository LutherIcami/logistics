-- =========================================================
-- FIX ANALYTICS FOR SNAKE_CASE SCHEMA (Likely Scenario)
-- =========================================================

-- 1. DROP EXISTING FUNCTIONS
DROP FUNCTION IF EXISTS get_driver_performance_stats();
DROP FUNCTION IF EXISTS get_weekly_revenue();
DROP FUNCTION IF EXISTS get_monthly_performance();
DROP FUNCTION IF EXISTS get_revenue_breakdown();
DROP FUNCTION IF EXISTS get_top_customers();

-- 2. DRIVER PERFORMANCE (Using snake_case)
CREATE OR REPLACE FUNCTION get_driver_performance_stats()
RETURNS TABLE (
    driver_id TEXT,
    driver_name TEXT,
    trips_completed BIGINT,
    rating DOUBLE PRECISION,
    earnings DOUBLE PRECISION,
    on_time_rate DOUBLE PRECISION,
    safety_incidents INT
) 
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.id::TEXT as driver_id,
        COALESCE(d.name, 'Unknown Driver') as driver_name,
        COALESCE(COUNT(CASE WHEN t.status = 'delivered' THEN 1 END), 0) as trips_completed,
        COALESCE(d.rating, 0.0)::DOUBLE PRECISION as rating,
        COALESCE(SUM(CASE 
            WHEN t.status = 'delivered' THEN 
                COALESCE(t.driver_earnings, t.total_cost * 0.7, 0) 
            ELSE 0 
        END), 0.0)::DOUBLE PRECISION as earnings,
        CASE 
            WHEN COUNT(CASE WHEN t.status = 'delivered' THEN 1 END) > 0 THEN
                COALESCE(
                    (COUNT(CASE 
                        WHEN t.status = 'delivered' 
                        AND t.delivery_date <= t.estimated_delivery 
                        THEN 1 
                    END)::DOUBLE PRECISION / NULLIF(COUNT(CASE WHEN t.status = 'delivered' THEN 1 END), 0)),
                    1.0
                )
            ELSE 1.0
        END as on_time_rate,
        0 as safety_incidents
    FROM drivers d
    LEFT JOIN trips t ON d.id = t.driver_id -- snake_case
    GROUP BY d.id, d.name, d.rating
    ORDER BY trips_completed DESC, rating DESC;
END;
$$ LANGUAGE plpgsql;

-- 3. WEEKLY REVENUE (Using snake_case for orders)
CREATE OR REPLACE FUNCTION get_weekly_revenue()
RETURNS TABLE (day TEXT, amount DECIMAL) 
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        to_char(date_trunc('day', COALESCE(order_date, created_at, NOW())), 'Dy') as day, -- order_date
        SUM(COALESCE(total_cost, 0))::DECIMAL as amount -- total_cost
    FROM orders
    WHERE (status NOT IN ('cancelled', 'failed') OR status IS NULL)
      AND COALESCE(order_date, created_at, NOW()) >= NOW() - INTERVAL '60 days'
    GROUP BY date_trunc('day', COALESCE(order_date, created_at, NOW()))
    ORDER BY date_trunc('day', COALESCE(order_date, created_at, NOW()));
END;
$$ LANGUAGE plpgsql;

-- 4. MONTHLY PERFORMANCE (Using snake_case)
CREATE OR REPLACE FUNCTION get_monthly_performance()
RETURNS TABLE (month TEXT, revenue DECIMAL, expenses DECIMAL) 
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    WITH monthly_data AS (
        SELECT
            date_trunc('month', COALESCE(t.assigned_date, t.created_at, NOW())) as m_date, -- assigned_date
            SUM(COALESCE(t.company_revenue, t.total_cost * 0.3, 0))::DECIMAL as m_revenue,
            SUM(COALESCE(t.driver_earnings, t.total_cost * 0.7, 0))::DECIMAL as m_expenses
        FROM trips t
        WHERE (t.status NOT IN ('cancelled', 'failed') OR t.status IS NULL)
          AND COALESCE(t.assigned_date, t.created_at, NOW()) >= NOW() - INTERVAL '12 months'
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

-- 5. REVENUE BREAKDOWN (Using snake_case)
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

-- 6. TOP CUSTOMERS (Using snake_case)
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
        COALESCE(SUM(o.total_cost), 0)::DECIMAL as total_spent, -- total_cost
        COUNT(o.id)::BIGINT as orders_count
    FROM customers c
    LEFT JOIN orders o ON c.id = o.customer_id -- customer_id
    GROUP BY c.id, c.name
    HAVING COUNT(o.id) > 0
    ORDER BY total_spent DESC
    LIMIT 5;
END;
$$ LANGUAGE plpgsql;

-- 7. GRANT PERMISSIONS
GRANT EXECUTE ON FUNCTION get_driver_performance_stats() TO authenticated, anon, service_role;
GRANT EXECUTE ON FUNCTION get_weekly_revenue() TO authenticated, anon, service_role;
GRANT EXECUTE ON FUNCTION get_monthly_performance() TO authenticated, anon, service_role;
GRANT EXECUTE ON FUNCTION get_revenue_breakdown() TO authenticated, anon, service_role;
GRANT EXECUTE ON FUNCTION get_top_customers() TO authenticated, anon, service_role;

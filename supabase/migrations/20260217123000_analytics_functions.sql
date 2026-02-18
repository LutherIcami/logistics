-- Create financial_transactions table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.financial_transactions (
    id TEXT PRIMARY KEY,
    type TEXT NOT NULL, -- 'income', 'expense'
    amount DECIMAL(12, 2) NOT NULL,
    date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    category TEXT, -- 'fuel', 'maintenance', 'salary', 'insurance', 'other' for expenses
    description TEXT,
    "referenceId" TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.financial_transactions ENABLE ROW LEVEL SECURITY;

-- Allow read access to authenticated users (admin mainly)
DROP POLICY IF EXISTS "Allow read access for authenticated users" ON public.financial_transactions;
CREATE POLICY "Allow read access for authenticated users" ON public.financial_transactions
    FOR SELECT USING (auth.role() = 'authenticated');

-- Function to get weekly revenue
CREATE OR REPLACE FUNCTION get_weekly_revenue()
RETURNS TABLE (day TEXT, amount DECIMAL) AS $$
BEGIN
    RETURN QUERY
    SELECT to_char(date_trunc('day', order_date), 'Dy') as day,
           SUM(total_cost) as amount
    FROM orders
    WHERE status IN ('delivered', 'confirmed')
      AND order_date >= NOW() - INTERVAL '7 days'
    GROUP BY date_trunc('day', order_date)
    ORDER BY date_trunc('day', order_date);
END;
$$ LANGUAGE plpgsql;

-- Function to get monthly performance (Revenue vs Expenses)
CREATE OR REPLACE FUNCTION get_monthly_performance()
RETURNS TABLE (month TEXT, revenue DECIMAL, expenses DECIMAL) AS $$
BEGIN
    RETURN QUERY
    WITH monthly_data AS (
        SELECT
            date_trunc('month', order_date) as m_date,
            SUM(total_cost) as m_revenue
        FROM orders
        WHERE status IN ('delivered', 'confirmed')
          AND order_date >= NOW() - INTERVAL '6 months'
        GROUP BY 1
    ),
    monthly_expenses AS (
        -- Calculate expenses from trips (driver earnings) + financial transactions
        SELECT
            date_trunc('month', t.created_at) as m_date,
            SUM(t.driver_earnings) as m_expenses
        FROM trips t
        WHERE t.status = 'delivered'
          AND t.created_at >= NOW() - INTERVAL '6 months'
        GROUP BY 1
    )
    SELECT
        to_char(d.m_date, 'Mon') as month,
        COALESCE(d.m_revenue, 0) as revenue,
        COALESCE(e.m_expenses, 0) as expenses
    FROM monthly_data d
    LEFT JOIN monthly_expenses e ON d.m_date = e.m_date
    ORDER BY d.m_date;
END;
$$ LANGUAGE plpgsql;

-- Function to get top customers
CREATE OR REPLACE FUNCTION get_top_customers()
RETURNS TABLE (name TEXT, revenue DECIMAL) AS $$
BEGIN
    RETURN QUERY
    SELECT customer_name as name,
           SUM(total_cost) as revenue
    FROM orders
    WHERE status IN ('delivered', 'confirmed')
    GROUP BY customer_name
    ORDER BY revenue DESC
    LIMIT 5;
END;
$$ LANGUAGE plpgsql;

-- Function to get driver performance stats
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
        COUNT(t.id) as trips_completed,
        COALESCE(AVG(t.rating), 0)::DOUBLE PRECISION as rating,
        COALESCE(SUM(t.driver_earnings), 0)::DOUBLE PRECISION as earnings,
        -- Calculate on-time rate manually if needed, simplified here
        (
            SELECT COUNT(*)::DOUBLE PRECISION / NULLIF(COUNT(*), 0)
            FROM trips t2 
            WHERE t2.driver_id = d.id AND t2.status = 'delivered' 
            -- AND t2.delivery_date <= t2.estimated_delivery
        ) as on_time_rate,
        0 as safety_incidents
    FROM drivers d
    LEFT JOIN trips t ON d.id = t.driver_id AND t.status = 'delivered'
    GROUP BY d.id, d.name;
END;
$$ LANGUAGE plpgsql;

-- Function to get expense breakdown
CREATE OR REPLACE FUNCTION get_expense_breakdown()
RETURNS TABLE (category TEXT, amount DECIMAL) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.category,
        SUM(t.amount) as amount
    FROM financial_transactions t
    WHERE t.type = 'expense'
    GROUP BY t.category;
END;
$$ LANGUAGE plpgsql;

-- Function to get shipment stats
CREATE OR REPLACE FUNCTION get_shipment_stats()
RETURNS TABLE (status TEXT, count BIGINT) AS $$
BEGIN
    RETURN QUERY
    SELECT
        o.status,
        COUNT(*) as count
    FROM orders o
    GROUP BY o.status;
END;
$$ LANGUAGE plpgsql;

-- Function to get average delivery time (in hours)
CREATE OR REPLACE FUNCTION get_avg_delivery_time()
RETURNS DOUBLE PRECISION AS $$
DECLARE
    avg_hours DOUBLE PRECISION;
BEGIN
    SELECT AVG(EXTRACT(EPOCH FROM (delivery_date - pickup_date))/3600)
    INTO avg_hours
    FROM orders
    WHERE status = 'delivered' AND pickup_date IS NOT NULL AND delivery_date IS NOT NULL;
    
    RETURN COALESCE(avg_hours, 0);
END;
$$ LANGUAGE plpgsql;

-- Function to get global on-time rate
CREATE OR REPLACE FUNCTION get_global_on_time_rate()
RETURNS DOUBLE PRECISION AS $$
DECLARE
    rate DOUBLE PRECISION;
BEGIN
    SELECT 
        COUNT(CASE WHEN delivery_date <= estimated_delivery THEN 1 END)::DOUBLE PRECISION / NULLIF(COUNT(*), 0)
    INTO rate
    FROM orders
    WHERE status = 'delivered' AND estimated_delivery IS NOT NULL;
    
    RETURN COALESCE(rate, 1.0); -- Default to 100% if no delivered orders
END;
$$ LANGUAGE plpgsql;

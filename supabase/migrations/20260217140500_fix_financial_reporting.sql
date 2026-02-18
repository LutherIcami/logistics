-- Fix financial reporting to properly show company revenue vs total revenue
-- and properly calculate expenses

-- 1. Update get_weekly_revenue to show both total revenue and company revenue
CREATE OR REPLACE FUNCTION get_weekly_revenue()
RETURNS TABLE (day TEXT, amount DECIMAL) AS $$
BEGIN
    RETURN QUERY
    SELECT to_char(date_trunc('day', "orderDate"), 'Dy') as day,
           SUM("totalCost") as amount
    FROM orders
    WHERE status IN ('delivered', 'confirmed')
      AND "orderDate" >= NOW() - INTERVAL '7 days'
    GROUP BY date_trunc('day', "orderDate")
    ORDER BY date_trunc('day', "orderDate");
END;
$$ LANGUAGE plpgsql;

-- 2. Update get_monthly_performance to show company revenue (not total revenue)
CREATE OR REPLACE FUNCTION get_monthly_performance()
RETURNS TABLE (month TEXT, revenue DECIMAL, expenses DECIMAL) AS $$
BEGIN
    RETURN QUERY
    WITH monthly_company_revenue AS (
        -- Company revenue from trips (company_revenue column)
        SELECT
            date_trunc('month', t."assignedDate") as m_date,
            SUM(COALESCE(t.company_revenue, 0)) as m_revenue
        FROM trips t
        WHERE t.status = 'delivered'
          AND t."assignedDate" >= NOW() - INTERVAL '6 months'
        GROUP BY 1
    ),
    monthly_expenses AS (
        -- Driver earnings as the main expense
        SELECT
            date_trunc('month', t."assignedDate") as m_date,
            SUM(COALESCE(t.driver_earnings, t."estimatedEarnings", 0)) as m_expenses
        FROM trips t
        WHERE t.status = 'delivered'
          AND t."assignedDate" >= NOW() - INTERVAL '6 months'
        GROUP BY 1
    )
    SELECT
        to_char(COALESCE(r.m_date, e.m_date), 'Mon') as month,
        COALESCE(r.m_revenue, 0) as revenue,
        COALESCE(e.m_expenses, 0) as expenses
    FROM monthly_company_revenue r
    FULL OUTER JOIN monthly_expenses e ON r.m_date = e.m_date
    ORDER BY COALESCE(r.m_date, e.m_date);
END;
$$ LANGUAGE plpgsql;

-- 3. Add a new function to get total revenue breakdown
CREATE OR REPLACE FUNCTION get_revenue_breakdown()
RETURNS TABLE (
    total_revenue DECIMAL,
    company_revenue DECIMAL,
    driver_earnings DECIMAL,
    company_percentage DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        SUM(COALESCE(t.total_cost, 0))::DECIMAL as total_revenue,
        SUM(COALESCE(t.company_revenue, 0))::DECIMAL as company_revenue,
        SUM(COALESCE(t.driver_earnings, t."estimatedEarnings", 0))::DECIMAL as driver_earnings,
        CASE 
            WHEN SUM(COALESCE(t.total_cost, 0)) > 0 THEN
                (SUM(COALESCE(t.company_revenue, 0)) / SUM(COALESCE(t.total_cost, 0)) * 100)::DECIMAL
            ELSE 0
        END as company_percentage
    FROM trips t
    WHERE t.status = 'delivered';
END;
$$ LANGUAGE plpgsql;

-- 4. Update the trips table trigger to also update orders table
CREATE OR REPLACE FUNCTION sync_trip_to_order_financials()
RETURNS TRIGGER AS $$
BEGIN
    -- When a trip's financial data is updated, sync it to the corresponding order
    IF NEW.id IS NOT NULL THEN
        UPDATE orders
        SET "totalCost" = NEW.total_cost
        WHERE id = NEW.id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_sync_trip_to_order_financials ON public.trips;
CREATE TRIGGER trigger_sync_trip_to_order_financials
AFTER INSERT OR UPDATE OF total_cost, driver_earnings, company_revenue ON public.trips
FOR EACH ROW EXECUTE FUNCTION sync_trip_to_order_financials();

-- 5. Ensure all existing trips have proper financial calculations
-- This will trigger the calculate_trip_financials function
UPDATE public.trips 
SET distance = COALESCE(distance, 0)
WHERE driver_earnings IS NULL OR company_revenue IS NULL;

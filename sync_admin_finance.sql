-- Trigger to auto-create financial transactions when a trip is delivered
CREATE OR REPLACE FUNCTION public.handle_trip_delivery_finance()
RETURNS TRIGGER AS $$
BEGIN
    -- Only act when status changes to 'delivered'
    IF (NEW.status = 'delivered' AND (OLD.status IS NULL OR OLD.status != 'delivered')) THEN
        -- Create an income transaction for the company's 30% cut
        INSERT INTO public.financial_transactions (
            id,
            type,
            amount,
            date,
            description,
            "referenceId",
            category
        ) VALUES (
            'TX-' || NEW.id, -- Unique ID based on trip
            'income',
            COALESCE(NEW.company_revenue, 0),
            NOW(),
            'Commission from Trip #' || NEW.id || ' (' || NEW."customerName" || ')',
            NEW.id,
            'commission'
        )
        ON CONFLICT (id) DO UPDATE SET
            amount = EXCLUDED.amount,
            description = EXCLUDED.description;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-create transaction on delivery
DROP TRIGGER IF EXISTS trigger_trip_delivery_finance ON public.trips;
CREATE TRIGGER trigger_trip_delivery_finance
AFTER UPDATE OF status ON public.trips
FOR EACH ROW EXECUTE FUNCTION public.handle_trip_delivery_finance();

-- Also ensure every trip is properly calculated on EVERY update to ensure company_revenue is present
-- (This replaces the previous trigger if it was only on specific columns)
CREATE OR REPLACE TRIGGER trigger_calculate_trip_financials
BEFORE INSERT OR UPDATE ON public.trips
FOR EACH ROW EXECUTE FUNCTION public.calculate_trip_financials();

-- Seed transactions for already delivered trips
INSERT INTO public.financial_transactions (id, type, amount, date, description, "referenceId", category)
SELECT 
    'TX-' || id,
    'income',
    company_revenue,
    COALESCE("deliveryDate", NOW()),
    'Commission from Trip #' || id || ' (' || "customerName" || ')',
    id,
    'commission'
FROM public.trips
WHERE status = 'delivered' AND company_revenue > 0
ON CONFLICT (id) DO NOTHING;

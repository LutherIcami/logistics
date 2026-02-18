-- Create the payments table to track M-Pesa transactions
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "orderId" TEXT REFERENCES public.orders(id),
    "customerId" UUID REFERENCES auth.users(id),
    amount DECIMAL(12, 2) NOT NULL,
    phone TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'success', 'failed'
    "checkoutRequestId" TEXT UNIQUE,
    "merchantRequestId" TEXT,
    result_code TEXT,
    result_desc TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

-- Policies
DROP POLICY IF EXISTS "Customers can view their own payments" ON public.payments;
CREATE POLICY "Customers can view their own payments" ON public.payments
    FOR SELECT USING (auth.uid() = "customerId");

-- Function to handle Safaricom Callback and update order/invoice
CREATE OR REPLACE FUNCTION handle_mpesa_callback()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'success' THEN
        -- Update the order status
        UPDATE public.orders 
        SET status = 'confirmed' -- Or whatever your 'paid' status is
        WHERE id = NEW."orderId";

        -- Insert into financial transactions
        INSERT INTO public.financial_transactions (
            id, type, amount, date, description, "referenceId"
        ) VALUES (
            'MPESA-' || NEW."checkoutRequestId",
            'income',
            NEW.amount,
            NOW(),
            'M-Pesa Payment for Order ' || NEW."orderId",
            NEW."orderId"
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_mpesa_payment_update ON public.payments;
CREATE TRIGGER on_mpesa_payment_update
    AFTER UPDATE ON public.payments
    FOR EACH ROW
    WHEN (OLD.status = 'pending' AND NEW.status = 'success')
    EXECUTE FUNCTION handle_mpesa_callback();

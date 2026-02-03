-- Create the invoices table
CREATE TABLE IF NOT EXISTS public.invoices (
    id TEXT PRIMARY KEY,
    "customerId" UUID NOT NULL REFERENCES auth.users(id),
    "customerName" TEXT NOT NULL,
    "issueDate" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    "dueDate" TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL DEFAULT 'draft',
    notes TEXT,
    "orderId" TEXT,
    items JSONB NOT NULL DEFAULT '[]',
    "totalAmount" DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create the financial_transactions table
CREATE TABLE IF NOT EXISTS public.financial_transactions (
    id TEXT PRIMARY KEY,
    type TEXT NOT NULL, -- 'income' or 'expense'
    amount DECIMAL(12, 2) NOT NULL,
    date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    description TEXT NOT NULL,
    "referenceId" TEXT, -- Link to invoice or other entity
    category TEXT, -- 'fuel', 'maintenance', etc.
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable RLS (Row Level Security)
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.financial_transactions ENABLE ROW LEVEL SECURITY;

-- Create policies (modify these based on your specific access needs)
-- For now, allowing all authenticated users (typical for an admin feature)
CREATE POLICY "Enable all for authenticated users" ON public.invoices
    FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Enable all for authenticated users" ON public.financial_transactions
    FOR ALL USING (auth.role() = 'authenticated');

-- Create triggers for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_invoices_updated_at
    BEFORE UPDATE ON public.invoices
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create Chat Messages Table linked by Order ID
CREATE TABLE IF NOT EXISTS public.chat_messages (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    order_id TEXT NOT NULL, -- Shared identifier for the order
    sender_id UUID NOT NULL REFERENCES auth.users(id),
    sender_name TEXT, -- Optional, to cache display name
    sender_role TEXT NOT NULL, -- 'driver', 'customer', 'admin'
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

-- Creates index for faster queries
CREATE INDEX IF NOT EXISTS idx_chat_order_id ON public.chat_messages(order_id);

-- POLICIES
-- 1. Allow any authenticated user to INSERT
CREATE POLICY "Allow authenticated insert" ON public.chat_messages
    FOR INSERT TO authenticated
    WITH CHECK (auth.uid() = sender_id);

-- 2. Allow users to SELECT messages
-- For MVP, allow authenticated users to read if they know the order_id
CREATE POLICY "Allow authenticated select" ON public.chat_messages
    FOR SELECT TO authenticated
    USING (true);

-- Enable Realtime
ALTER TABLE public.chat_messages REPLICA IDENTITY FULL;
-- Note: You might need to add it to the publication manually if not already there:
-- alter publication supabase_realtime add table chat_messages;

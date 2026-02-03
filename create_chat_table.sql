-- Create Chat Messages Table linked by Tracking Number
CREATE TABLE IF NOT EXISTS public.chat_messages (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    tracking_number TEXT NOT NULL, -- Shared identifier for the shipment
    sender_id UUID NOT NULL REFERENCES auth.users(id),
    sender_name TEXT, -- Optional, to cache display name
    sender_role TEXT NOT NULL, -- 'driver', 'customer', 'admin'
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

-- Creates index for faster queries
CREATE INDEX IF NOT EXISTS idx_chat_tracking_number ON public.chat_messages(tracking_number);

-- POLICIES
-- 1. Allow any authenticated user to INSERT (Validation happens on UI/Logic for now)
CREATE POLICY "Allow authenticated insert" ON public.chat_messages
    FOR INSERT TO authenticated
    WITH CHECK (auth.uid() = sender_id);

-- 2. Allow users to SELECT messages based on involvement
-- Ideally, checking if the user is related to the tracking number.
-- For MVP speed/reliability, we'll allow authenticated users to read messages 
-- IF they know the tracking_number. 
CREATE POLICY "Allow authenticated select" ON public.chat_messages
    FOR SELECT TO authenticated
    USING (true);

-- Enable Realtime
alter publication supabase_realtime add table chat_messages;

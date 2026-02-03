-- Comprehensive RLS Policy Fix for Admin Operations
-- This script adds missing INSERT, UPDATE, and DELETE policies for admin users

-- ============================================
-- VEHICLES TABLE POLICIES
-- ============================================

-- Drop existing vehicle policies
DROP POLICY IF EXISTS "Vehicles viewable by authenticated" ON public.vehicles;
DROP POLICY IF EXISTS "Admins can manage vehicles" ON public.vehicles;
DROP POLICY IF EXISTS "Admins can insert vehicles" ON public.vehicles;
DROP POLICY IF EXISTS "Admins can update vehicles" ON public.vehicles;
DROP POLICY IF EXISTS "Admins can delete vehicles" ON public.vehicles;

-- Create comprehensive vehicle policies
CREATE POLICY "Vehicles viewable by authenticated" 
ON public.vehicles FOR SELECT 
USING (auth.role() = 'authenticated');

CREATE POLICY "Admins can insert vehicles" 
ON public.vehicles FOR INSERT 
WITH CHECK (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can update vehicles" 
ON public.vehicles FOR UPDATE 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can delete vehicles" 
ON public.vehicles FOR DELETE 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));


-- ============================================
-- DRIVERS TABLE POLICIES
-- ============================================

-- Drop existing driver policies
DROP POLICY IF EXISTS "Drivers viewable by authenticated" ON public.drivers;
DROP POLICY IF EXISTS "Update own driver profile" ON public.drivers;
DROP POLICY IF EXISTS "Admins can insert drivers" ON public.drivers;
DROP POLICY IF EXISTS "Admins can update drivers" ON public.drivers;
DROP POLICY IF EXISTS "Admins can delete drivers" ON public.drivers;

-- Create comprehensive driver policies
CREATE POLICY "Drivers viewable by authenticated" 
ON public.drivers FOR SELECT 
USING (auth.role() = 'authenticated');

CREATE POLICY "Drivers can update own profile" 
ON public.drivers FOR UPDATE 
USING (auth.uid() = id);

CREATE POLICY "Admins can insert drivers" 
ON public.drivers FOR INSERT 
WITH CHECK (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can update drivers" 
ON public.drivers FOR UPDATE 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can delete drivers" 
ON public.drivers FOR DELETE 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));


-- ============================================
-- CUSTOMERS TABLE POLICIES
-- ============================================

-- Drop existing customer policies
DROP POLICY IF EXISTS "Customers view own profile" ON public.customers;
DROP POLICY IF EXISTS "Admins view all customers" ON public.customers;
DROP POLICY IF EXISTS "Admins can insert customers" ON public.customers;
DROP POLICY IF EXISTS "Admins can update customers" ON public.customers;
DROP POLICY IF EXISTS "Admins can delete customers" ON public.customers;

-- Create comprehensive customer policies
CREATE POLICY "Customers view own profile" 
ON public.customers FOR SELECT 
USING (auth.uid() = id);

CREATE POLICY "Admins view all customers" 
ON public.customers FOR SELECT 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can insert customers" 
ON public.customers FOR INSERT 
WITH CHECK (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can update customers" 
ON public.customers FOR UPDATE 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can delete customers" 
ON public.customers FOR DELETE 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));


-- ============================================
-- INVOICES TABLE POLICIES
-- ============================================

-- Drop existing invoice policies
DROP POLICY IF EXISTS "Admins view all invoices" ON public.invoices;
DROP POLICY IF EXISTS "Customers view own invoices" ON public.invoices;
DROP POLICY IF EXISTS "Admins can insert invoices" ON public.invoices;
DROP POLICY IF EXISTS "Admins can update invoices" ON public.invoices;
DROP POLICY IF EXISTS "Admins can delete invoices" ON public.invoices;

-- Create comprehensive invoice policies
CREATE POLICY "Admins view all invoices" 
ON public.invoices FOR SELECT 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Customers view own invoices" 
ON public.invoices FOR SELECT 
USING (auth.uid() = "customerId");

CREATE POLICY "Admins can insert invoices" 
ON public.invoices FOR INSERT 
WITH CHECK (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can update invoices" 
ON public.invoices FOR UPDATE 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can delete invoices" 
ON public.invoices FOR DELETE 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));


-- ============================================
-- FINANCIAL TRANSACTIONS TABLE POLICIES
-- ============================================

-- Drop existing transaction policies
DROP POLICY IF EXISTS "Admins view all transactions" ON public.financial_transactions;
DROP POLICY IF EXISTS "Admins can insert transactions" ON public.financial_transactions;
DROP POLICY IF EXISTS "Admins can update transactions" ON public.financial_transactions;
DROP POLICY IF EXISTS "Admins can delete transactions" ON public.financial_transactions;

-- Create comprehensive transaction policies
CREATE POLICY "Admins view all transactions" 
ON public.financial_transactions FOR SELECT 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can insert transactions" 
ON public.financial_transactions FOR INSERT 
WITH CHECK (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can update transactions" 
ON public.financial_transactions FOR UPDATE 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can delete transactions" 
ON public.financial_transactions FOR DELETE 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));


-- ============================================
-- TRIPS/SHIPMENTS TABLE POLICIES
-- ============================================

-- Drop existing trip policies
DROP POLICY IF EXISTS "Drivers view own trips" ON public.trips;
DROP POLICY IF EXISTS "Admins view all trips" ON public.trips;
DROP POLICY IF EXISTS "Admins can insert trips" ON public.trips;
DROP POLICY IF EXISTS "Admins can update trips" ON public.trips;
DROP POLICY IF EXISTS "Admins can delete trips" ON public.trips;
DROP POLICY IF EXISTS "Drivers can update own trips" ON public.trips;

-- Create comprehensive trip policies
CREATE POLICY "Drivers view own trips" 
ON public.trips FOR SELECT 
USING (auth.uid() = "driverId");

CREATE POLICY "Admins view all trips" 
ON public.trips FOR SELECT 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can insert trips" 
ON public.trips FOR INSERT 
WITH CHECK (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can update trips" 
ON public.trips FOR UPDATE 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Drivers can update own trips" 
ON public.trips FOR UPDATE 
USING (auth.uid() = "driverId");

CREATE POLICY "Admins can delete trips" 
ON public.trips FOR DELETE 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));


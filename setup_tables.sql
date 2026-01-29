
-- Comprehensive Supabase Setup Script - CLEANED VERSION (With CamelCase Fixes)

-- 1. Profiles Table (Core Auth)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    role TEXT DEFAULT 'customer',
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Drivers Table
CREATE TABLE IF NOT EXISTS public.drivers (
    id UUID REFERENCES public.profiles(id) ON DELETE CASCADE PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT NOT NULL,
    "licenseNumber" TEXT,
    "licenseExpiry" TEXT,
    status TEXT DEFAULT 'active',
    rating DOUBLE PRECISION DEFAULT 0.0,
    "totalTrips" INTEGER DEFAULT 0,
    "currentLocation" TEXT,
    "currentVehicle" TEXT,
    "joinDate" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "profileImage" TEXT,
    "additionalInfo" JSONB
);

-- 3. Vehicles Table
CREATE TABLE IF NOT EXISTS public.vehicles (
    id TEXT PRIMARY KEY,
    "registrationNumber" TEXT NOT NULL,
    make TEXT NOT NULL,
    model TEXT NOT NULL,
    year INTEGER NOT NULL,
    type TEXT DEFAULT 'truck',
    status TEXT DEFAULT 'active',
    "assignedDriverId" UUID REFERENCES public.profiles(id),
    "assignedDriverName" TEXT,
    "fuelCapacity" DOUBLE PRECISION DEFAULT 0.0,
    "currentFuelLevel" DOUBLE PRECISION DEFAULT 0.0,
    mileage DOUBLE PRECISION DEFAULT 0.0,
    "purchaseDate" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "lastMaintenanceDate" TIMESTAMP WITH TIME ZONE,
    "nextMaintenanceDate" TIMESTAMP WITH TIME ZONE,
    "currentLocation" TEXT,
    "loadCapacity" DOUBLE PRECISION,
    "insuranceExpiry" TEXT,
    "licenseExpiry" TEXT,
    "purchasePrice" DOUBLE PRECISION,
    "currentValue" DOUBLE PRECISION,
    specifications JSONB,
    "additionalInfo" JSONB
);

-- 4. Trips Table
CREATE TABLE IF NOT EXISTS public.trips (
    id TEXT PRIMARY KEY,
    "driverId" UUID REFERENCES public.profiles(id) NOT NULL,
    "driverName" TEXT,
    "pickupLocation" TEXT NOT NULL,
    "deliveryLocation" TEXT NOT NULL,
    "customerName" TEXT NOT NULL,
    "customerPhone" TEXT,
    status TEXT DEFAULT 'assigned',
    "assignedDate" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "pickupDate" TIMESTAMP WITH TIME ZONE,
    "deliveryDate" TIMESTAMP WITH TIME ZONE,
    "estimatedDelivery" TIMESTAMP WITH TIME ZONE,
    "vehicleId" TEXT,
    "vehiclePlate" TEXT,
    "cargoType" TEXT NOT NULL,
    "cargoWeight" DOUBLE PRECISION,
    "specialInstructions" TEXT,
    distance DOUBLE PRECISION,
    "estimatedEarnings" DOUBLE PRECISION,
    "additionalInfo" JSONB
);

-- 5. Orders Table
CREATE TABLE IF NOT EXISTS public.orders (
    id TEXT PRIMARY KEY,
    "customerId" UUID REFERENCES public.profiles(id) NOT NULL,
    "customerName" TEXT NOT NULL,
    "pickupLocation" TEXT NOT NULL,
    "deliveryLocation" TEXT NOT NULL,
    status TEXT DEFAULT 'pending',
    "orderDate" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "pickupDate" TIMESTAMP WITH TIME ZONE,
    "deliveryDate" TIMESTAMP WITH TIME ZONE,
    "estimatedDelivery" TIMESTAMP WITH TIME ZONE,
    "driverId" UUID REFERENCES public.profiles(id),
    "driverName" TEXT,
    "vehiclePlate" TEXT,
    "cargoType" TEXT NOT NULL,
    "cargoWeight" DOUBLE PRECISION,
    "specialInstructions" TEXT,
    distance DOUBLE PRECISION,
    "totalCost" DOUBLE PRECISION DEFAULT 0.0,
    "trackingNumber" TEXT,
    "additionalInfo" JSONB
);

-- 6. Customers Table
CREATE TABLE IF NOT EXISTS public.customers (
    id UUID REFERENCES public.profiles(id) ON DELETE CASCADE PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT NOT NULL,
    "companyName" TEXT,
    address TEXT,
    city TEXT,
    country TEXT,
    "joinDate" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "totalOrders" INTEGER DEFAULT 0,
    "totalSpent" DOUBLE PRECISION DEFAULT 0.0,
    "profileImage" TEXT,
    "additionalInfo" JSONB
);

-- Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.drivers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trips ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;

-- Policies

-- Profiles
CREATE POLICY "Public profiles are viewable by everyone." ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can insert their own profile." ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update own profile." ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Drivers
CREATE POLICY "Drivers viewable by authenticated" ON public.drivers FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Update own driver profile" ON public.drivers FOR UPDATE USING (auth.uid() = id);

-- Vehicles
CREATE POLICY "Vehicles viewable by authenticated" ON public.vehicles FOR SELECT USING (auth.role() = 'authenticated');

-- Trips
CREATE POLICY "Drivers view own trips" ON public.trips FOR SELECT USING (auth.uid() = "driverId");
CREATE POLICY "Admins view all trips" ON public.trips FOR SELECT USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

-- Orders
CREATE POLICY "Customers view own orders" ON public.orders FOR SELECT USING (auth.uid() = "customerId");
CREATE POLICY "Admins view all orders" ON public.orders FOR SELECT USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));
CREATE POLICY "Customers can insert their own orders" ON public.orders FOR INSERT WITH CHECK (auth.uid() = "customerId");

-- Customers
CREATE POLICY "Customers view own profile" ON public.customers FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Admins view all customers" ON public.customers FOR SELECT USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

-- Trigger for New User Profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, role)
  VALUES (new.id, new.email, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'role');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to call the function when a new user is created
CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Finance Tables
CREATE TABLE IF NOT EXISTS public.invoices (
    id TEXT PRIMARY KEY,
    "customerId" UUID REFERENCES public.profiles(id),
    "customerName" TEXT NOT NULL,
    "issueDate" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "dueDate" TIMESTAMP WITH TIME ZONE,
    status TEXT DEFAULT 'draft',
    notes TEXT,
    items JSONB NOT NULL,
    "totalAmount" DOUBLE PRECISION DEFAULT 0.0
);

CREATE TABLE IF NOT EXISTS public.financial_transactions (
    id TEXT PRIMARY KEY,
    type TEXT NOT NULL, -- 'income', 'expense'
    amount DOUBLE PRECISION NOT NULL,
    date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    description TEXT NOT NULL,
    "referenceId" TEXT,
    category TEXT -- 'fuel', 'maintenance', etc.
);

-- Enable RLS
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.financial_transactions ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Admins view all invoices" ON public.invoices FOR SELECT USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));
CREATE POLICY "Admins view all transactions" ON public.financial_transactions FOR SELECT USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));
CREATE POLICY "Customers view own invoices" ON public.invoices FOR SELECT USING (auth.uid() = "customerId");


-- System Settings Table
CREATE TABLE IF NOT EXISTS public.system_settings (
    id INTEGER PRIMARY KEY CHECK (id = 1), -- Ensure only one row
    "baseOrderRate" DOUBLE PRECISION DEFAULT 2000.0,
    "distanceRate" DOUBLE PRECISION DEFAULT 25.0,
    "weightRate" DOUBLE PRECISION DEFAULT 0.5,
    "enableRegistration" BOOLEAN DEFAULT TRUE,
    "maintenanceThresholdDays" INTEGER DEFAULT 30,
    "driverDownloadLink" TEXT DEFAULT 'https://your-app-link.com/download',
    currency TEXT DEFAULT 'KES'
);

-- Initialize settings if not exists
INSERT INTO public.system_settings (id) 
SELECT 1 WHERE NOT EXISTS (SELECT 1 FROM public.system_settings WHERE id = 1);

-- Enable RLS
ALTER TABLE public.system_settings ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Admins can manage system settings" ON public.system_settings FOR ALL USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));
CREATE POLICY "All users can view system settings" ON public.system_settings FOR SELECT USING (TRUE);

-- Create storage buckets for profile images and vehicle images
INSERT INTO storage.buckets (id, name, public) 
VALUES ('customer-profiles', 'customer-profiles', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public) 
VALUES ('vehicle-images', 'vehicle-images', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public) 
VALUES ('driver-profiles', 'driver-profiles', true)
ON CONFLICT (id) DO NOTHING;

-- Policies for customer-profiles bucket
-- 1. Public can view profiles
CREATE POLICY "Public Access" ON storage.objects FOR SELECT USING (bucket_id = 'customer-profiles');

-- 2. Authenticated users can upload their own profile image
CREATE POLICY "Authenticated Upload" ON storage.objects FOR INSERT 
WITH CHECK (bucket_id = 'customer-profiles' AND auth.role() = 'authenticated');

-- 3. Users can update/delete their own objects
CREATE POLICY "Owner Edit" ON storage.objects FOR UPDATE 
USING (bucket_id = 'customer-profiles' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "Owner Delete" ON storage.objects FOR DELETE 
USING (bucket_id = 'customer-profiles' AND (storage.foldername(name))[1] = auth.uid()::text);


-- Policies for vehicle-images bucket (Admins only for modification)
CREATE POLICY "Public View Vehicles" ON storage.objects FOR SELECT USING (bucket_id = 'vehicle-images');

CREATE POLICY "Admin Modify Vehicles" ON storage.objects 
FOR ALL USING (
    bucket_id = 'vehicle-images' AND 
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
);


-- Policies for driver-profiles bucket
CREATE POLICY "Public View Drivers" ON storage.objects FOR SELECT USING (bucket_id = 'driver-profiles');

CREATE POLICY "Admin/Driver Modify Profiles" ON storage.objects 
FOR ALL USING (
    bucket_id = 'driver-profiles' AND 
    (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin') OR
        (storage.foldername(name))[1] = auth.uid()::text
    )
);

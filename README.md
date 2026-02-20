Projo is a scalable logistics system built using Feature-First Clean Architecture and a secure Database-as-Backend philosophy.

It supports:

Real-time fleet monitoring

Automated driver onboarding

Shipment lifecycle management

Revenue analytics

Mobile money payments (M-Pesa)

Secure row-level data isolation

🏗️ Architecture

This project follows Feature-First Clean Architecture to ensure maintainability and scalability.

lib/
 ├── core/              # Shared utilities, themes, services
 ├── features/
 │    ├── admin/
 │    ├── driver/
 │    ├── customer/
 │    └── chat/
 ├── main.dart

🔹 Core Layer

Reusable widgets, themes, helpers, and network utilities.

🔹 Feature Modules

Each feature contains:

data/

domain/

presentation/

🔹 State Management

Provider Pattern

Reactive UI updates

🔹 Navigation

GoRouter with structured routing

🌟 Features
🏢 Administrator Dashboard

🚚 Live fleet monitoring (vehicle health & fuel levels)

📊 Financial analytics (revenue, expenses, top customers via fl_chart)

🧠 Intelligent shipment assignment

⚙️ Global system controls & carrier configuration

🚛 Driver Experience

🔐 Secure onboarding via Supabase Edge Functions

📦 Trip status management
assigned → in_transit → delivered

💰 Automated 70/30 commission calculation

🗺️ Smart navigation (Google / Apple Maps deep linking)

👤 Customer Portal

📦 Create detailed cargo shipments

📍 Real-time shipment tracking

💳 M-Pesa STK Push integration

👤 Manage profile & saved delivery addresses

🛠️ Technology Stack
Layer	Technology
Frontend	Flutter (Dart)
Backend	Supabase (PostgreSQL)
Authentication	Supabase Auth
Real-Time	PostgreSQL Triggers + Realtime
Cloud Logic	Supabase Edge Functions (Deno)
Security	Row Level Security (RLS)
Email Service	Resend API
Payments	M-Pesa Daraja API
🛡️ Security Model

Projo follows a Database-As-The-Backend Philosophy.

🔐 Row Level Security (RLS)

Customers only see their orders

Drivers only see assigned trips

Admin has controlled elevated access

⚙️ PostgreSQL Triggers

Trip → Order status syncing

Revenue calculations

Commission automation

🔑 Secrets Management

Stored securely in Supabase environment variables

No API keys exposed in client app

🚀 Getting Started
✅ Prerequisites

Flutter SDK (latest stable)

Supabase project

Android Studio / VS Code

1️⃣ Database Setup

Run SQL scripts in Supabase SQL Editor:

setup_tables.sql

fix_all_tables_snake_case.sql

sync_trip_to_order_v4.sql

2️⃣ Configure Environment

Update Supabase credentials:

await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_ANON_KEY',
);

3️⃣ Install Dependencies
flutter pub get

4️⃣ Run Application
flutter run

📊 Roadmap

 Web Dashboard Version

 Push Notifications

 Offline Driver Mode

 AI Route Optimization

 Multi-Country Support

🤝 Contributing

Contributions are welcome.

Fork the repo

Create a feature branch

Submit a pull request

For major changes, open an issue first.

📄 License

This project is currently private.

❤️ Built for Advanced Logistics

Designed to power modern fleet operations with security, scalability, and real-time intelligence.

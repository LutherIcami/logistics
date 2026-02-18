# Financial Model Documentation

## Overview
This document explains how the financial calculations work in the logistics system.

## Revenue Split Model

### Total Cost Calculation
When a trip/order is created, the total cost is calculated using:
```
Total Cost = Base Rate + (Distance × Distance Rate) + (Weight × Weight Rate)
```

**Default Rates:**
- Base Rate: KES 2,000
- Distance Rate: KES 25 per km
- Weight Rate: KES 0.5 per kg

### Revenue Distribution
The total cost is split between the driver and the company:

```
Driver Earnings = Total Cost × Driver Commission Rate (default: 70%)
Company Revenue = Total Cost × (1 - Driver Commission Rate) (default: 30%)
```

**Example:**
- Total Cost: KES 10,000
- Driver Earnings: KES 7,000 (70%)
- Company Revenue: KES 3,000 (30%)

## Database Schema

### Trips Table Columns
- `total_cost`: Total amount charged to customer
- `driver_earnings`: Amount paid to driver (70% of total)
- `company_revenue`: Amount kept by company (30% of total)
- `estimatedEarnings`: Legacy field, kept in sync with `driver_earnings`

### Orders Table Columns
- `totalCost`: Synced from trips.total_cost

## Financial Reports

### Revenue Chart
Shows **Company Revenue** (not total revenue) over time. This is the actual money the company keeps after paying drivers.

### Expense Chart
Shows **Driver Earnings** as the primary expense. This represents payments to drivers.

### Profit Calculation
```
Profit = Company Revenue - Other Expenses
Net Margin = Profit / Total Cost
```

## Analytics Functions

### `get_monthly_performance()`
Returns monthly data:
- `revenue`: Company's revenue (30% of total)
- `expenses`: Driver earnings (70% of total)

### `get_revenue_breakdown()`
Returns overall breakdown:
- `total_revenue`: Total customer payments
- `company_revenue`: Company's share
- `driver_earnings`: Drivers' share
- `company_percentage`: Company's percentage

### `get_driver_performance_stats()`
Returns per-driver statistics:
- `trips_completed`: Number of delivered trips
- `earnings`: Total driver earnings
- `on_time_rate`: Percentage of on-time deliveries
- `rating`: Driver's average rating

## Important Notes

1. **Revenue vs Total Revenue**: The charts show company revenue (after driver commission), not total customer payments.

2. **Automatic Calculation**: Financial fields are automatically calculated via database triggers when trips are created or updated.

3. **Commission Rate**: The driver commission rate can be adjusted in `system_settings` table (default: 0.7 or 70%).

4. **Sync**: Trip financials are automatically synced to the orders table.

## Modifying Commission Rates

To change the driver commission rate:
```sql
UPDATE system_settings 
SET "driverCommissionRate" = 0.65  -- 65% to driver, 35% to company
WHERE id = 1;
```

After changing, update existing trips:
```sql
UPDATE trips SET distance = distance;
```

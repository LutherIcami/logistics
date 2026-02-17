# M-Pesa STK Push Integration Guide

I have implemented the M-Pesa STK Push functionality in your Flutter app and prepared the Supabase backend. Follow these steps to complete the setup:

## 1. Supabase Backend Setup

### Database migration
I have created a migration file at `supabase/migrations/create_payments_table.sql`. 
- Open the **Supabase Dashboard** -> **SQL Editor**.
- Copy and run the contents of that file to create the `payments` table and the triggers that automatically update your `orders` table when a payment succeeds.

### Edge Functions
I have created two new Supabase Edge Functions:
1. `mpesa-stk-push`: Initiates the pin prompt on the user's phone.
2. `mpesa-callback`: Receives the result from Safaricom.

To deploy these, run the following commands in your terminal:
```bash
supabase functions deploy mpesa-stk-push
supabase functions deploy mpesa-callback
```

## 2. Environment Variables
You need to set your Safaricom Daraja API keys in Supabase. You can get these from the [Safaricom Developer Portal](https://developer.safaricom.co.ke/).

Run these commands (replace with your keys):
```bash
supabase secrets set MPESA_CONSUMER_KEY=your_key
supabase secrets set MPESA_CONSUMER_SECRET=your_secret
supabase secrets set MPESA_SHORTCODE=174379
supabase secrets set MPESA_PASSKEY=bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919
supabase secrets set MPESA_CALLBACK_URL=https://your-project-ref.supabase.co/functions/v1/mpesa-callback
```
*Note: The keys above are for the Safaricom Sandbox environment.*

## 3. Flutter App Usage
The "Pay with M-Pesa" button is now visible in the **Order Details** page for any order that is in `pending` or `confirmed` status.

### How it works:
1. When the user clicks **Pay with M-Pesa**, it triggers the `mpesa-stk-push` Edge Function.
2. The user receives a popup on their phone asking for their M-Pesa PIN.
3. Once they enter the PIN, Safaricom sends a result to the `mpesa-callback` function.
4. The database trigger `on_mpesa_payment_update` automatically updates the Order status to `confirmed` and creates a record in `financial_transactions`.

## Testing
For Sandbox testing, use the Safaricom Sandbox credentials and a test phone number provided in the Daraja portal.

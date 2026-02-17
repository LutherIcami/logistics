import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const MPESA_CONSUMER_KEY = Deno.env.get('MPESA_CONSUMER_KEY')
const MPESA_CONSUMER_SECRET = Deno.env.get('MPESA_CONSUMER_SECRET')
const MPESA_SHORTCODE = Deno.env.get('MPESA_SHORTCODE')
const MPESA_PASSKEY = Deno.env.get('MPESA_PASSKEY')
const MPESA_CALLBACK_URL = Deno.env.get('MPESA_CALLBACK_URL')

serve(async (req) => {
    const { phone, amount, orderId } = await req.json()

    try {
        // 1. Get Access Token
        const auth = btoa(`${MPESA_CONSUMER_KEY}:${MPESA_CONSUMER_SECRET}`)
        const tokenResponse = await fetch("https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials", {
            headers: { Authorization: `Basic ${auth}` }
        })
        const { access_token } = await tokenResponse.json()

        // 2. Prepare STK Push
        const timestamp = new Date().toISOString().replace(/[-:T]/g, '').slice(0, 14)
        const password = btoa(`${MPESA_SHORTCODE}${MPESA_PASSKEY}${timestamp}`)

        const stkResponse = await fetch("https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest", {
            method: 'POST',
            headers: {
                Authorization: `Bearer ${access_token}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                BusinessShortCode: MPESA_SHORTCODE,
                Password: password,
                Timestamp: timestamp,
                TransactionType: 'CustomerPayBillOnline',
                Amount: amount,
                PartyA: phone,
                PartyB: MPESA_SHORTCODE,
                PhoneNumber: phone,
                CallBackURL: MPESA_CALLBACK_URL,
                AccountReference: `Order-${orderId}`,
                TransactionDesc: `Logistics Payment for Order ${orderId}`
            })
        })

        const data = await stkResponse.json()

        // 3. Record in Database
        const supabase = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
        )

        await supabase.from('payments').insert({
            orderId,
            amount,
            phone,
            checkoutRequestId: data.CheckoutRequestID,
            merchantRequestId: data.MerchantRequestID,
            status: 'pending'
        })

        return new Response(JSON.stringify(data), { status: 200 })
    } catch (error) {
        return new Response(JSON.stringify({ error: error.message }), { status: 500 })
    }
})

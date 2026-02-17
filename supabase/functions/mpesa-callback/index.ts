import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
    const body = await req.json()
    const result = body.Body.stkCallback

    const supabase = createClient(
        Deno.env.get('SUPABASE_URL') ?? '',
        Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const checkoutRequestId = result.CheckoutRequestID
    const resultCode = result.ResultCode
    const resultDesc = result.ResultDesc

    const status = resultCode === 0 ? 'success' : 'failed'

    await supabase
        .from('payments')
        .update({
            status,
            result_code: resultCode.toString(),
            result_desc: resultDesc
        })
        .eq('checkoutRequestId', checkoutRequestId)

    return new Response(JSON.stringify({ message: "Callback received" }), { status: 200 })
})

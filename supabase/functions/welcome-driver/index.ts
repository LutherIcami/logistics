import { createClient } from "supabase"

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')

Deno.serve(async (req) => {
    const { email, name, role } = await req.json()

    try {
        const supabaseAdmin = createClient(SUPABASE_URL!, SUPABASE_SERVICE_ROLE_KEY!)

        // 1. Invite the user via Supabase Auth
        // This generates the magic link/invite internally
        const { data: inviteData, error: inviteError } = await supabaseAdmin.auth.admin.inviteUserByEmail(email, {
            data: { full_name: name, role: role },
            // Redirect to your app's deep link or reset password page
            redirectTo: 'io.supabase.projo://reset-password',
        })

        if (inviteError) throw inviteError

        // 2. Send the custom beautiful email via Resend
        const res = await fetch('https://api.resend.com/emails', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${RESEND_API_KEY}`,
            },
            body: JSON.stringify({
                from: 'Logistics Pro <onboarding@yourdomain.com>',
                to: email,
                subject: 'Welcome to the Fleet, ' + name + '!',
                html: `
          <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #e2e8f0; border-radius: 12px; padding: 32px; color: #1e293b;">
            <h1 style="color: #2563eb; margin-top: 0; font-size: 24px;">Welcome to Logistics Pro!</h1>
            <p style="font-size: 16px; line-height: 1.5;">Hello ${name},</p>
            <p style="font-size: 16px; line-height: 1.5;">You've been added as a <strong>${role}</strong>. Please follow these <strong>two simple steps</strong> to get started:</p>
            
            <div style="background: #f8fafc; padding: 20px; border-radius: 8px; margin: 24px 0; border: 1px solid #cbd5e1;">
              <h2 style="font-size: 18px; color: #0f172a; margin-top: 0;">Step 1: Download the App</h2>
              <p style="font-size: 14px; color: #64748b; margin-bottom: 20px;">Install the official driver app to receive assignments and track trips.</p>
              <a href="YOUR_APK_DOWNLOAD_LINK_HERE" style="background: #0f172a; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block; font-weight: 600;">Download Android App (APK)</a>
            </div>

            <div style="background: #f0f9ff; padding: 20px; border-radius: 8px; margin: 24px 0; border: 1px solid #bae6fd;">
              <h2 style="font-size: 18px; color: #0369a1; margin-top: 0;">Step 2: Secure Your Account</h2>
              <p style="font-size: 14px; color: #0c4a6e; margin-bottom: 20px;">Once the app is installed, click the button below to set your password and log in.</p>
              <a href="${inviteData.user.action_link}" style="background: #2563eb; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block; font-weight: 600;">Secure My Account</a>
            </div>

            <hr style="margin: 32px 0; border: 0; border-top: 1px solid #e2e8f0;" />
            <p style="font-size: 12px; color: #94a3b8; text-align: center;">&copy; 2026 Logistics Pro Management System. All rights reserved.</p>
          </div>
        `,
            }),
        })

        const resData = await res.json()

        return new Response(JSON.stringify({
            success: true,
            message: 'Invite sent',
            userId: inviteData.user.id, // Explicitly return the UUID
            data: resData
        }), {
            headers: { 'Content-Type': 'application/json' },
            status: 200,
        })
    } catch (error) {
        return new Response(JSON.stringify({ success: false, error: error.message }), {
            headers: { 'Content-Type': 'application/json' },
            status: 400,
        })
    }
})

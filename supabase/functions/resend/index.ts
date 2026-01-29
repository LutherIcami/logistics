import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "supabase"

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

Deno.serve(async (req) => {
  try {
    const { email, name, role } = await req.json()
    const supabaseAdmin = createClient(SUPABASE_URL!, SUPABASE_SERVICE_ROLE_KEY!)

    // 1. Generate the invite link (this does NOT send an email)
    const { data: inviteData, error: inviteError } = await supabaseAdmin.auth.admin.generateLink({
      type: 'invite',
      email: email,
      options: {
        data: { full_name: name, role: role },
        redirectTo: 'io.supabase.projo://reset-password',
      }
    })

    if (inviteError) throw inviteError

    const action_link = inviteData.properties.action_link;

    // 2. Send custom email using Resend
    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${RESEND_API_KEY}`,
      },
      body: JSON.stringify({
        from: 'Logistics Pro <onboarding@resend.dev>', // Use resend.dev for testing if no domain verified
        to: email,
        subject: `Welcome to the Fleet, ${name}!`,
        html: `
          <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e2e8f0; border-radius: 12px;">
            <h1 style="color: #1d4ed8; margin-top: 0;">Logistics Pro</h1>
            <p style="font-size: 16px; color: #334155;">Hello ${name},</p>
            <p style="font-size: 16px; color: #334155;">You have been onboarded as a <strong>${role}</strong>. To get started, please secure your account by setting your password.</p>
            
            <div style="margin: 32px 0;">
              <a href="${action_link}" style="background-color: #1d4ed8; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; font-weight: 600; display: inline-block;">Set Your Password</a>
            </div>

            <p style="font-size: 14px; color: #64748b;">If the button above doesn't work, copy and paste this link into your browser:</p>
            <p style="font-size: 12px; color: #94a3b8; word-break: break-all;">${action_link}</p>
            
            <hr style="border: 0; border-top: 1px solid #e2e8f0; margin: 32px 0;" />
            <p style="font-size: 12px; color: #94a3b8; text-align: center;">&copy; 2026 Logistics Pro Management System</p>
          </div>
        `,
      }),
    })

    const resData = await res.json()

    return new Response(
      JSON.stringify({ success: true, userId: inviteData.user.id, resend: resData }),
      { headers: { "Content-Type": "application/json" } },
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 400, headers: { "Content-Type": "application/json" } },
    )
  }
})

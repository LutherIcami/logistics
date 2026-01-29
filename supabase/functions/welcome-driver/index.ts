import { createClient } from "supabase"

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')

Deno.serve(async (req) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', {
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'POST',
                'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
            }
        })
    }

    try {
        const { email, name, role, download_link, password } = await req.json()

        if (!email || !name) {
            throw new Error('Email and Name are required fields.')
        }

        const supabaseAdmin = createClient(
            SUPABASE_URL!,
            SUPABASE_SERVICE_ROLE_KEY!,
            {
                auth: {
                    autoRefreshToken: false,
                    persistSession: false,
                },
            }
        )

        const finalDownloadLink = download_link || "https://your-app-link.com/download";
        let action_link = '';
        let userId = '';

        if (password) {
            // DIRECT CREATION: Admin provided a password
            const { data: userData, error: userError } = await supabaseAdmin.auth.admin.createUser({
                email: email,
                password: password,
                email_confirm: true,
                user_metadata: { full_name: name, role: role || 'driver' }
            })

            if (userError) throw userError
            userId = userData.user.id
        } else {
            // INVITATION MODE: No password provided, send invite link
            const { data: inviteData, error: inviteError } = await supabaseAdmin.auth.admin.generateLink({
                type: 'invite',
                email: email,
                options: {
                    data: { full_name: name, role: role || 'driver' },
                    redirectTo: 'io.supabase.projo://reset-password',
                }
            })

            if (inviteError) throw inviteError
            action_link = inviteData.properties.action_link
            userId = inviteData.user.id
        }

        // Send Welcome Email
        const htmlContent = password
            ? `
          <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #e2e8f0; border-radius: 16px; overflow: hidden; color: #1e293b; background-color: #ffffff;">
            <div style="background-color: #0f172a; padding: 40px 32px; text-align: center;">
              <h1 style="color: #ffffff; margin: 0; font-size: 28px;">Logistics Pro</h1>
            </div>
            <div style="padding: 40px 32px;">
              <h2 style="color: #0f172a;">Welcome to the Fleet, ${name}!</h2>
              <p>Your driver account has been created by the administrator. Use the credentials below to log in to the mobile app.</p>
              
              <div style="background-color: #f8fafc; padding: 24px; border-radius: 12px; margin: 24px 0;">
                <p style="margin: 0; font-size: 14px;"><strong>Email:</strong> ${email}</p>
                <p style="margin: 8px 0 0; font-size: 14px;"><strong>Password:</strong> (Provided by your administrator)</p>
              </div>

              <a href="${finalDownloadLink}" style="display: inline-block; background-color: #2563eb; color: #ffffff; padding: 14px 28px; text-decoration: none; border-radius: 8px; font-weight: 600;">Download the App</a>
            </div>
          </div>`
            : `
          <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #e2e8f0; border-radius: 16px; overflow: hidden; color: #1e293b; background-color: #ffffff;">
            <div style="background-color: #0f172a; padding: 40px 32px; text-align: center;">
              <h1 style="color: #ffffff; margin: 0; font-size: 28px;">Logistics Pro</h1>
            </div>
            <div style="padding: 40px 32px;">
              <h2 style="color: #0f172a;">Welcome aboard, ${name}!</h2>
              <p>You have been invited to join our logistics platform. Please secure your account and download the app below.</p>
              <div style="margin: 24px 0; display: flex; flex-direction: column; gap: 12px;">
                <a href="${action_link}" style="display: inline-block; background-color: #2563eb; color: #ffffff; padding: 14px 28px; text-decoration: none; border-radius: 8px; font-weight: 600; text-align: center;">Secure My Account</a>
                <a href="${finalDownloadLink}" style="display: inline-block; background-color: #0f172a; color: #ffffff; padding: 14px 28px; text-decoration: none; border-radius: 8px; font-weight: 600; text-align: center;">Download the App</a>
              </div>
            </div>
          </div>`;

        await fetch('https://api.resend.com/emails', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${RESEND_API_KEY}`,
            },
            body: JSON.stringify({
                from: 'Logistics Pro <onboarding@resend.dev>',
                to: email,
                subject: `Welcome to Logistics Pro, ${name}!`,
                html: htmlContent,
            }),
        })

        return new Response(JSON.stringify({
            success: true,
            userId: userId,
            mode: password ? 'direct' : 'invite'
        }), {
            headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
            status: 200,
        })

    } catch (error) {
        return new Response(JSON.stringify({ success: false, error: error.message }), {
            headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
            status: 400,
        })
    }
})

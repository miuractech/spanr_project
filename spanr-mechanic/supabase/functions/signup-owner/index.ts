// Retired. Owners now sign up with phone OTP (see auth.service.ts), and the old
// email flow was an unauthenticated endpoint that could overwrite the password
// of any unconfirmed account and enumerate registered emails.
//
// Deploying this stub replaces the vulnerable version; afterwards remove it with
//   supabase functions delete signup-owner
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

serve(() =>
  new Response(JSON.stringify({ error: 'This signup method is no longer available' }), {
    status: 410,
    headers: { 'Content-Type': 'application/json' },
  })
);

// Supabase Edge Function to create a Razorpay order for an existing payments row.
//
// The amount is never taken from the client: the caller passes a payment_id,
// we confirm the payment belongs to one of the caller's orders, then bill
// exactly payments.amount. The Razorpay order id is written back with the
// service role so clients cannot re-point a payment at a cheaper Razorpay order.
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }
  if (req.method !== 'POST') {
    return json({ error: 'Method not allowed' }, 405);
  }

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return json({ error: 'Unauthorized' }, 401);
    }

    const { payment_id } = await req.json().catch(() => ({}));
    if (typeof payment_id !== 'string' || !UUID_RE.test(payment_id)) {
      return json({ error: 'payment_id is required' }, 400);
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
    const razorpayKeyId = Deno.env.get('RAZORPAY_KEY_ID');
    const razorpayKeySecret = Deno.env.get('RAZORPAY_KEY_SECRET');

    if (!razorpayKeyId || !razorpayKeySecret) {
      console.error('Razorpay credentials not configured');
      return json({ error: 'Payments are temporarily unavailable' }, 500);
    }

    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const adminClient = createClient(supabaseUrl, serviceKey);

    const { data: { user }, error: userError } = await userClient.auth.getUser();
    if (userError || !user) {
      return json({ error: 'Unauthorized' }, 401);
    }

    const { data: payment, error: paymentError } = await adminClient
      .from('payments')
      .select('id, order_id, amount, status, kind, razorpay_order_id, orders!inner(user_id)')
      .eq('id', payment_id)
      .single();
    if (paymentError || !payment) {
      return json({ error: 'Payment not found' }, 404);
    }

    const orderOwner = (payment as { orders?: { user_id?: string } }).orders?.user_id;
    if (orderOwner !== user.id) {
      return json({ error: 'Payment not found' }, 404);
    }

    if (payment.status !== 'unpaid') {
      return json({ error: 'This payment is no longer awaiting checkout' }, 409);
    }

    const amountPaise = Math.round(Number(payment.amount) * 100);
    if (!Number.isFinite(amountPaise) || amountPaise < 100) {
      return json({ error: 'Invalid payment amount' }, 400);
    }

    const auth = btoa(`${razorpayKeyId}:${razorpayKeySecret}`);

    // Retrying checkout must reuse the attached Razorpay order. Replacing it
    // would orphan the old one: if that one were still paid, the webhook could
    // no longer match the money to this payment.
    if (payment.razorpay_order_id) {
      const existingResponse = await fetch(
        `https://api.razorpay.com/v1/orders/${encodeURIComponent(payment.razorpay_order_id)}`,
        { headers: { 'Authorization': `Basic ${auth}` } },
      );
      if (existingResponse.ok) {
        const existing = await existingResponse.json();
        if (existing.status === 'paid') {
          return json({ error: 'This payment has already been made' }, 409);
        }
        if (existing.amount === amountPaise) {
          return json({ id: existing.id, amount: existing.amount, currency: existing.currency });
        }
      }
    }

    const razorpayResponse = await fetch('https://api.razorpay.com/v1/orders', {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${auth}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        amount: amountPaise,
        currency: 'INR',
        // Razorpay caps receipt at 40 chars; a UUID is 36.
        receipt: payment.id,
        notes: { payment_id: payment.id, order_id: payment.order_id, kind: payment.kind },
      }),
    });

    if (!razorpayResponse.ok) {
      console.error('Razorpay API error:', razorpayResponse.status, await razorpayResponse.text());
      return json({ error: 'Could not start payment. Please try again.' }, 502);
    }

    const order = await razorpayResponse.json();

    const { error: attachError } = await adminClient
      .from('payments')
      .update({ razorpay_order_id: order.id })
      .eq('id', payment.id)
      .eq('status', 'unpaid');
    if (attachError) {
      console.error('Failed to attach Razorpay order:', attachError);
      return json({ error: 'Could not start payment. Please try again.' }, 500);
    }

    return json({ id: order.id, amount: order.amount, currency: order.currency });
  } catch (error) {
    console.error('Error creating Razorpay order:', error);
    return json({ error: 'Could not start payment. Please try again.' }, 500);
  }
});

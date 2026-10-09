// Confirms a Razorpay Checkout success without waiting for the webhook.
// Verifies the checkout signature, checks the payment on Razorpay's API,
// captures if still authorized (common in test mode), then marks paid.
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

function hexFromBuffer(buf: ArrayBuffer): string {
  return [...new Uint8Array(buf)]
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}

async function hmacSha256Hex(secret: string, message: string): Promise<string> {
  const key = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const digest = await crypto.subtle.sign(
    'HMAC',
    key,
    new TextEncoder().encode(message),
  );
  return hexFromBuffer(digest);
}

function signaturesMatch(expectedHex: string, received: string): boolean {
  const a = expectedHex.trim().toLowerCase();
  const b = received.trim().toLowerCase();
  if (a.length !== b.length || a.length === 0) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) {
    diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  }
  return diff === 0;
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }
  if (req.method !== 'POST') {
    return json({ error: 'Method not allowed' }, 405);
  }

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) return json({ error: 'Unauthorized' }, 401);

    const body = await req.json().catch(() => ({})) as Record<string, unknown>;
    const paymentId = body.payment_id;
    const razorpayOrderId = body.razorpay_order_id;
    const razorpayPaymentId = body.razorpay_payment_id;
    const razorpaySignature = body.razorpay_signature;

    if (
      typeof paymentId !== 'string' ||
      !UUID_RE.test(paymentId) ||
      typeof razorpayOrderId !== 'string' ||
      !razorpayOrderId.startsWith('order_') ||
      typeof razorpayPaymentId !== 'string' ||
      !razorpayPaymentId.startsWith('pay_') ||
      typeof razorpaySignature !== 'string' ||
      razorpaySignature.length < 16
    ) {
      return json({ error: 'Invalid payment confirmation' }, 400);
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
    const razorpayKeyId = Deno.env.get('RAZORPAY_KEY_ID');
    const razorpayKeySecret = Deno.env.get('RAZORPAY_KEY_SECRET');

    if (!razorpayKeyId || !razorpayKeySecret) {
      return json({ error: 'Payments are temporarily unavailable' }, 500);
    }

    const expected = await hmacSha256Hex(
      razorpayKeySecret,
      `${razorpayOrderId}|${razorpayPaymentId}`,
    );
    if (!signaturesMatch(expected, razorpaySignature)) {
      return json({ error: 'Invalid payment signature' }, 401);
    }

    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const adminClient = createClient(supabaseUrl, serviceKey);

    const { data: { user }, error: userError } = await userClient.auth.getUser();
    if (userError || !user) return json({ error: 'Unauthorized' }, 401);

    const { data: payment, error: paymentError } = await adminClient
      .from('payments')
      .select('id, order_id, amount, status, razorpay_order_id, orders!inner(user_id)')
      .eq('id', paymentId)
      .single();
    if (paymentError || !payment) {
      return json({ error: 'Payment not found' }, 404);
    }

    const ordersRel = (payment as { orders?: { user_id?: string } | { user_id?: string }[] }).orders;
    const orderOwner = Array.isArray(ordersRel) ? ordersRel[0]?.user_id : ordersRel?.user_id;
    if (orderOwner !== user.id) {
      return json({ error: 'Payment not found' }, 404);
    }

    if (payment.status === 'paid') {
      return json({ status: 'paid' });
    }
    if (payment.status === 'failed') {
      return json({ error: 'This payment has already failed' }, 409);
    }

    if (
      payment.razorpay_order_id &&
      payment.razorpay_order_id !== razorpayOrderId
    ) {
      return json({ error: 'Payment order mismatch' }, 409);
    }

    const auth = btoa(`${razorpayKeyId}:${razorpayKeySecret}`);
    const rzpRes = await fetch(
      `https://api.razorpay.com/v1/payments/${encodeURIComponent(razorpayPaymentId)}`,
      { headers: { Authorization: `Basic ${auth}` } },
    );
    if (!rzpRes.ok) {
      console.error('Razorpay payment fetch failed', rzpRes.status, await rzpRes.text());
      return json({ error: 'Could not confirm payment' }, 502);
    }
    const rzp = await rzpRes.json() as {
      status?: string;
      amount?: number;
      currency?: string;
      order_id?: string;
    };

    if (rzp.order_id !== razorpayOrderId) {
      return json({ error: 'Payment order mismatch' }, 409);
    }

    const expectedPaise = Math.round(Number(payment.amount) * 100);
    if (Number(rzp.amount) !== expectedPaise || (rzp.currency && rzp.currency !== 'INR')) {
      return json({ error: 'Amount mismatch' }, 409);
    }

    if (rzp.status === 'authorized') {
      const captureRes = await fetch(
        `https://api.razorpay.com/v1/payments/${encodeURIComponent(razorpayPaymentId)}/capture`,
        {
          method: 'POST',
          headers: {
            Authorization: `Basic ${auth}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ amount: expectedPaise, currency: 'INR' }),
        },
      );
      if (!captureRes.ok) {
        console.error('Razorpay capture failed', captureRes.status, await captureRes.text());
        return json({ error: 'Could not capture payment' }, 502);
      }
    } else if (rzp.status !== 'captured') {
      return json({ error: `Payment is ${rzp.status ?? 'unknown'}` }, 409);
    }

    const { error: updateError } = await adminClient
      .from('payments')
      .update({
        status: 'paid',
        paid_at: new Date().toISOString(),
        razorpay_order_id: razorpayOrderId,
        razorpay_payment_id: razorpayPaymentId,
        razorpay_signature: razorpaySignature,
        updated_at: new Date().toISOString(),
      })
      .eq('id', payment.id)
      .in('status', ['unpaid', 'processing']);
    if (updateError) {
      console.error('Failed to mark payment paid', updateError);
      return json({ error: 'Could not confirm payment' }, 500);
    }

    return json({ status: 'paid' });
  } catch (error) {
    console.error('verify payment error', error);
    return json({ error: 'Could not confirm payment' }, 500);
  }
});

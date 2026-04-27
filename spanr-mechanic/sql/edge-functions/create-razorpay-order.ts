// Supabase Edge Function to create Razorpay order
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import Razorpay from 'npm:razorpay@2.9.2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { amount, currency, receipt } = await req.json();

    // Validate input
    if (!amount || !currency || !receipt) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields: amount, currency, receipt' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Initialize Razorpay
    const razorpay = new Razorpay({
      key_id: Deno.env.get('RAZORPAY_KEY_ID'),
      key_secret: Deno.env.get('RAZORPAY_KEY_SECRET'),
    });

    // Create Razorpay order
    const order = await razorpay.orders.create({
      amount, // amount in paise
      currency,
      receipt,
    });

    return new Response(
      JSON.stringify(order),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  } catch (error) {
    console.error('Error creating Razorpay order:', error);
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  }
});


import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { createHmac } from "https://deno.land/std@0.177.0/node/crypto.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, x-razorpay-signature",
};

interface RazorpayWebhookPayload {
  entity: string;
  account_id: string;
  event: string;
  contains: string[];
  payload: {
    payment: {
      entity: {
        id: string;
        entity: string;
        amount: number;
        currency: string;
        status: string;
        order_id: string;
        invoice_id: string | null;
        international: boolean;
        method: string;
        amount_refunded: number;
        refund_status: string | null;
        captured: boolean;
        description: string;
        card_id: string | null;
        bank: string | null;
        wallet: string | null;
        vpa: string | null;
        email: string;
        contact: string;
        notes: Record<string, any>;
        fee: number;
        tax: number;
        error_code: string | null;
        error_description: string | null;
        error_source: string | null;
        error_step: string | null;
        error_reason: string | null;
        created_at: number;
      };
    };
  };
  created_at: number;
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const razorpayWebhookSecret = Deno.env.get("RAZORPAY_WEBHOOK_SECRET");
    if (!razorpayWebhookSecret) {
      throw new Error("Razorpay webhook secret not configured");
    }

    // Get signature from headers
    const signature = req.headers.get("x-razorpay-signature");
    if (!signature) {
      return new Response(
        JSON.stringify({ error: "No signature provided" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Get request body
    const body = await req.text();
    
    // Verify signature
    const expectedSignature = createHmac("sha256", razorpayWebhookSecret)
      .update(body)
      .digest("hex");

    if (signature !== expectedSignature) {
      console.error("Invalid webhook signature");
      return new Response(
        JSON.stringify({ error: "Invalid signature" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Parse the webhook payload
    const webhookData: RazorpayWebhookPayload = JSON.parse(body);
    console.log("Webhook event received:", webhookData.event);

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Handle different event types
    if (webhookData.event === "payment.captured") {
      const payment = webhookData.payload.payment.entity;
      
      // Find payment record by razorpay_order_id
      const { data: paymentRecord, error: findError } = await supabase
        .from("payments")
        .select("*")
        .eq("razorpay_order_id", payment.order_id)
        .single();

      if (findError) {
        console.error("Error finding payment:", findError);
        return new Response(
          JSON.stringify({ error: "Payment record not found" }),
          { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      // Store webhook event
      await supabase.from("payment_webhook_events").insert({
        payment_id: paymentRecord.id,
        event_type: webhookData.event,
        razorpay_event_id: payment.id,
        payload: webhookData.payload,
        processed: false,
      });

      // Only update payment status if not already paid (prevent overwriting)
      // Update only if current status is 'unpaid' or 'processing'
      const { error: updateError } = await supabase
        .from("payments")
        .update({
          status: "paid",
          razorpay_payment_id: payment.id,
          paid_at: new Date(payment.created_at * 1000).toISOString(),
          updated_at: new Date().toISOString(),
        })
        .eq("id", paymentRecord.id)
        .in("status", ["unpaid", "processing"]);

      if (updateError) {
        console.error("Error updating payment:", updateError);
        throw updateError;
      }

      // Mark webhook as processed
      await supabase
        .from("payment_webhook_events")
        .update({ processed: true })
        .eq("razorpay_event_id", payment.id);

      console.log("Payment captured and updated successfully:", paymentRecord.id);
    } 
    else if (webhookData.event === "payment.failed") {
      const payment = webhookData.payload.payment.entity;
      
      // Find payment record
      const { data: paymentRecord, error: findError } = await supabase
        .from("payments")
        .select("*")
        .eq("razorpay_order_id", payment.order_id)
        .single();

      if (findError) {
        console.error("Error finding payment:", findError);
        return new Response(
          JSON.stringify({ error: "Payment record not found" }),
          { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      // Store webhook event
      await supabase.from("payment_webhook_events").insert({
        payment_id: paymentRecord.id,
        event_type: webhookData.event,
        razorpay_event_id: payment.id,
        payload: webhookData.payload,
        processed: false,
      });

      // Only update payment status if not already in a final state
      // Update only if current status is 'unpaid' or 'processing'
      const failureReason = payment.error_description || payment.error_reason || "Payment failed";
      const { error: updateError } = await supabase
        .from("payments")
        .update({
          status: "failed",
          failure_reason: failureReason,
          updated_at: new Date().toISOString(),
        })
        .eq("id", paymentRecord.id)
        .in("status", ["unpaid", "processing"]);

      if (updateError) {
        console.error("Error updating payment:", updateError);
        throw updateError;
      }

      // Mark webhook as processed
      await supabase
        .from("payment_webhook_events")
        .update({ processed: true })
        .eq("razorpay_event_id", payment.id);

      console.log("Payment failed and updated:", paymentRecord.id);
    }

    return new Response(
      JSON.stringify({ success: true }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Webhook error:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});


import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, x-razorpay-signature",
};

function hexFromBuffer(buf: ArrayBuffer): string {
  return [...new Uint8Array(buf)]
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

/** Razorpay: HMAC-SHA256(webhook_secret, raw_body) as lowercase hex */
async function verifyRazorpaySignature(
  rawBody: string,
  signatureHeader: string,
  secret: string,
): Promise<boolean> {
  const keyMaterial = secret.trim();
  const received = signatureHeader.trim().toLowerCase();
  if (!keyMaterial || !received) return false;

  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(keyMaterial),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const digest = await crypto.subtle.sign(
    "HMAC",
    key,
    new TextEncoder().encode(rawBody),
  );
  const expected = hexFromBuffer(digest).toLowerCase();
  if (expected.length !== received.length) return false;
  let diff = 0;
  for (let i = 0; i < expected.length; i++) {
    diff |= expected.charCodeAt(i) ^ received.charCodeAt(i);
  }
  return diff === 0;
}

type PaymentEntity = {
  id: string;
  order_id: string;
  created_at?: number;
};

/** Razorpay nests payment as { entity }, or rarely as the entity object itself / array. */
function extractPaymentEntityFlexible(
  payload: Record<string, unknown>,
  orderIdFallback?: string | null,
): PaymentEntity | null {
  const raw = payload.payment;
  const candidates: Partial<PaymentEntity>[] = [];

  if (raw != null && typeof raw === "object" && !Array.isArray(raw)) {
    const wrapped = raw as { entity?: Partial<PaymentEntity> };
    if (wrapped.entity && typeof wrapped.entity === "object") {
      candidates.push(wrapped.entity);
    }
    if ("id" in wrapped && "order_id" in wrapped) {
      candidates.push(wrapped as Partial<PaymentEntity>);
    }
  }
  if (Array.isArray(raw) && raw.length > 0) {
    const first = raw[0] as { entity?: Partial<PaymentEntity> } | Partial<PaymentEntity>;
    if (first && typeof first === "object" && "entity" in first) {
      candidates.push((first as { entity: Partial<PaymentEntity> }).entity);
    } else if (first && typeof first === "object") {
      candidates.push(first as Partial<PaymentEntity>);
    }
  }

  for (const c of candidates) {
    const id = c.id;
    const orderId = c.order_id ?? orderIdFallback;
    if (id && orderId != null) {
      return {
        id,
        order_id: orderId,
        created_at: c.created_at,
      };
    }
  }
  return null;
}

function extractRazorpayOrderIdFromPayload(payload: Record<string, unknown>): string | null {
  const order = payload.order as { entity?: { id?: string } } | undefined;
  const id = order?.entity?.id;
  return typeof id === "string" && id.length > 0 ? id : null;
}

/** Id + timestamps when order_id is only known from order.paid / order block */
function extractPaymentIdOnly(
  payload: Record<string, unknown>,
): { id: string; created_at?: number } | null {
  const raw = payload.payment;
  if (raw != null && typeof raw === "object" && !Array.isArray(raw)) {
    const w = raw as { entity?: { id?: string; created_at?: number } };
    if (w.entity?.id) return { id: w.entity.id, created_at: w.entity.created_at };
    if ("id" in raw && typeof (raw as { id?: string }).id === "string") {
      return {
        id: (raw as { id: string }).id,
        created_at: (raw as { created_at?: number }).created_at,
      };
    }
  }
  return null;
}

type PaidCaptureContext = {
  razorpayOrderId: string;
  razorpayPaymentId: string | null;
  createdAtSeconds?: number;
};

function resolvePaidCaptureContext(
  event: string | undefined,
  payload: Record<string, unknown>,
): PaidCaptureContext | null {
  const fromOrder = extractRazorpayOrderIdFromPayload(payload);
  const p = extractPaymentEntityFlexible(payload, fromOrder);
  if (p) {
    return {
      razorpayOrderId: p.order_id,
      razorpayPaymentId: p.id,
      createdAtSeconds: p.created_at,
    };
  }
  if (fromOrder) {
    const idOnly = extractPaymentIdOnly(payload);
    if (idOnly) {
      return {
        razorpayOrderId: fromOrder,
        razorpayPaymentId: idOnly.id,
        createdAtSeconds: idOnly.created_at,
      };
    }
  }
  if (event === "order.paid" && fromOrder) {
    return {
      razorpayOrderId: fromOrder,
      razorpayPaymentId: null,
      createdAtSeconds: Math.floor(Date.now() / 1000),
    };
  }
  return null;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const razorpayWebhookSecret = Deno.env.get("RAZORPAY_WEBHOOK_SECRET");
    if (!razorpayWebhookSecret?.trim()) {
      throw new Error("Razorpay webhook secret not configured");
    }

    const signature = req.headers.get("x-razorpay-signature");
    if (!signature) {
      return new Response(
        JSON.stringify({ error: "No signature provided" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const body = await req.text();
    const valid = await verifyRazorpaySignature(body, signature, razorpayWebhookSecret);
    if (!valid) {
      console.error("Invalid webhook signature", {
        bodyLength: body.length,
        headerLength: signature.trim().length,
      });
      return new Response(
        JSON.stringify({ error: "Invalid signature" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const webhookData = JSON.parse(body) as {
      event?: string;
      payload?: Record<string, unknown>;
    };
    const event = webhookData.event;
    console.log("Webhook event received:", event);

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const payload = webhookData.payload ?? {};

    if (event === "payment.captured" || event === "order.paid") {
      const ctx = resolvePaidCaptureContext(event, payload);
      if (!ctx) {
        console.error("Paid webhook: could not resolve order/payment", {
          event,
          keys: Object.keys(payload),
        });
        return new Response(
          JSON.stringify({
            error: "Unrecognized payload for paid webhook",
            event: event ?? null,
          }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }

      const webhookRef =
        ctx.razorpayPaymentId ?? `${event ?? "paid"}:${ctx.razorpayOrderId}`;

      const { data: paymentRecord, error: findError } = await supabase
        .from("payments")
        .select("*")
        .eq("razorpay_order_id", ctx.razorpayOrderId)
        .single();

      if (findError) {
        console.error("Error finding payment:", findError);
        return new Response(
          JSON.stringify({ error: "Payment record not found" }),
          { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }

      await supabase.from("payment_webhook_events").insert({
        payment_id: paymentRecord.id,
        event_type: event,
        razorpay_event_id: webhookRef,
        payload,
        processed: false,
      });

      const paidAtSeconds = ctx.createdAtSeconds ?? Math.floor(Date.now() / 1000);
      const patch: Record<string, unknown> = {
        status: "paid",
        paid_at: new Date(paidAtSeconds * 1000).toISOString(),
        updated_at: new Date().toISOString(),
      };
      if (ctx.razorpayPaymentId) {
        patch.razorpay_payment_id = ctx.razorpayPaymentId;
      }

      const { error: updateError } = await supabase
        .from("payments")
        .update(patch)
        .eq("id", paymentRecord.id)
        .in("status", ["unpaid", "processing"]);

      if (updateError) {
        console.error("Error updating payment:", updateError);
        throw updateError;
      }

      await supabase
        .from("payment_webhook_events")
        .update({ processed: true })
        .eq("razorpay_event_id", webhookRef);

      console.log(`${event}: payment marked paid`, paymentRecord.id);
    } else if (event === "payment.failed") {
      const orderFb = extractRazorpayOrderIdFromPayload(payload);
      const payment = extractPaymentEntityFlexible(payload, orderFb);
      if (!payment) {
        console.error("Failed webhook: missing payment context", {
          event,
          keys: Object.keys(payload),
        });
        return new Response(
          JSON.stringify({
            error: "Unrecognized payload for failed payment webhook",
            event: event ?? null,
          }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }

      const { data: paymentRecord, error: findError } = await supabase
        .from("payments")
        .select("*")
        .eq("razorpay_order_id", payment.order_id)
        .single();

      if (findError) {
        console.error("Error finding payment:", findError);
        return new Response(
          JSON.stringify({ error: "Payment record not found" }),
          { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }

      await supabase.from("payment_webhook_events").insert({
        payment_id: paymentRecord.id,
        event_type: event,
        razorpay_event_id: payment.id,
        payload,
        processed: false,
      });

      const pe = payload.payment as {
        entity?: {
          error_description?: string | null;
          error_reason?: string | null;
        };
      };
      const ent = pe?.entity ?? {};
      const failureReason =
        ent.error_description || ent.error_reason || "Payment failed";

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

      await supabase
        .from("payment_webhook_events")
        .update({ processed: true })
        .eq("razorpay_event_id", payment.id);

      console.log("Payment failed and updated:", paymentRecord.id);
    }

    return new Response(
      JSON.stringify({ success: true }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (error) {
    console.error("Webhook error:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});

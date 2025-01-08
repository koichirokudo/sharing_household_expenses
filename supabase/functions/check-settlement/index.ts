import {serve} from "https://deno.land/std@0.182.0/http/server.ts";
import {createClient} from "https://esm.sh/v135/@supabase/supabase-js@2.14.0/dist/module/index.js";
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import {corsHeaders} from "../_shared/cors.ts";

console.log("Check settlement function");

serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const body = await request.json();
  const { visibility, month } = body;

  if (!month) {
    return new Response(
      JSON.stringify({ success: false, error: "Missing required fields" }),
      { status: 400 },
    );
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
      {
        global: {
          headers: { Authorization: request.headers.get("Authorization")! },
        },
      },
    );

    // Get current user
    const { data: { user }, error: userError } = await supabaseClient.auth
      .getUser();
    if (userError || !user) {
      throw new Error("Error fetching user.");
    }

    // Get user profile
    const { data: profile, error: profileError } = await supabaseClient
      .from("profiles")
      .select("group_id")
      .eq("id", user.id)
      .single();
    if (profileError || !profile) {
      throw new Error("Error fetching user profile.");
    }

    // Get settlements
    const { data: settlement, error: settlementsError } = await supabaseClient
      .from("settlements")
      .select("*")
      .eq("group_id", profile.group_id)
      .eq("visibility", visibility)
      .eq("status", "completed")
      .eq("settlement_date", month)
      .single();
    if (settlementsError || !settlement) {
      throw new Error("Error fetching settlements.");
    }

    let isSettlement = false;
    if (settlement.length > 0) {
      isSettlement = true;
    }

    return new Response(
      JSON.stringify({ success: true, isSettlement: isSettlement }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      },
    );
  } catch (error) {
    console.error(error);
    if (error instanceof Error) {
      return new Response(
        JSON.stringify({ success: false, error: error.message }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 200,
        },
      );
    } else {
      return new Response(
        JSON.stringify({ success: false, error: "Unknown error occurred" }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 200,
        },
      );
    }
  }
});

import {serve} from "https://deno.land/std@0.182.0/http/server.ts";
import {createClient} from "https://esm.sh/@supabase/supabase-js@2.14.0";
import {corsHeaders} from "../_shared/cors.ts";
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

console.log("Generate group invite code function");

serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Create instance of SupabaseClient
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
    if (userError || !user) throw new Error("No user found for JWT!");

    // Get user profile
    const { data: profile, error: profileError } = await supabaseClient
      .from("profiles") // Assuming profile information is stored in 'profiles' table
      .select("group_id")
      .eq("id", user.id)
      .single();
    if (profileError) throw new Error("Error fetching user profile.");

    // Generate random string
    const N = 8;
    const array = new Uint8Array(N);
    crypto.getRandomValues(array);
    const inviteCode = btoa(String.fromCharCode(...array)).substring(0, N);

    // Update user group invite code
    const now = new Date().toISOString();
    const limit = new Date(Date.now() + 20 * 60 * 1000).toISOString();
    await supabaseClient.from("user_groups").update({
      "invite_code": inviteCode,
      "invite_limit": limit, // late 20 min
      "updated_at": now,
    }).eq("id", profile.group_id);

    // Response
    return new Response(
      JSON.stringify({ success: true, inviteCode: inviteCode }),
      {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
        status: 200,
      },
    );
  } catch (error) {
    console.error(error);
    if (error instanceof Error) {
      return new Response(
        JSON.stringify({ success: false, error: error.message }),
        {
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
          status: 200,
        },
      );
    } else {
      return new Response(
        JSON.stringify({
          success: false,
          error: "Unknown error occurred",
        }),
        {
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
          status: 200,
        },
      );
    }
  }
});

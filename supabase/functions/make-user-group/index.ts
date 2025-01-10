import {serve} from "https://deno.land/std@0.182.0/http/server.ts";
import {createClient} from "https://esm.sh/v135/@supabase/supabase-js@2.14.0/dist/module/index.js";
import {corsHeaders} from "../_shared/cors.ts";

console.log("Make user group function");

serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
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
    if (userError || !user) throw new Error("再度ログインして実行してください");

    const now = new Date().toISOString();
    const N = 10;
    const array = new Uint8Array(N);
    crypto.getRandomValues(array);
    const groupName = btoa(String.fromCharCode(...array)).substring(0, N);
    // 期限切れかつ10文字で入れておく
    const inviteCode = btoa(String.fromCharCode(...array)).substring(0, N);

    // Make user group
    const { data: group, error: groupError } = await supabaseClient.from(
      "user_groups",
    ).insert({
      "group_name": groupName,
      "slug": groupName,
      "invite_code": inviteCode,
      "invite_limit": now,
      "start_day": 1,
      "created_at": now,
      "updated_at": now,
    }).select("*").single();

    if (groupError || !group) {
      throw new Error("再度ログインして実行してください");
    }

    // Update profile
    await supabaseClient.from("profiles").update({
      "group_id": group.id,
      "invite_status": "accepted",
      "invited_at": now,
      "updated_at": now,
    }).eq("id", user.id);

    return new Response(
      JSON.stringify({ success: true }),
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

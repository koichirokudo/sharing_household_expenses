import {serve} from "https://deno.land/std@0.182.0/http/server.ts";
import {createClient} from "https://esm.sh/v135/@supabase/supabase-js@2.14.0/dist/module/index.js";
import {corsHeaders} from "../_shared/cors.ts";
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

console.log("Update transaction function");

serve(async (request) => {
  const body = await request.json();
  const { transaction } = body;
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

    const { data: updatedTransaction, error: upsertError } =
      await supabaseClient.from("transactions").upsert(transaction).select();

    if (upsertError) {
      throw new Error("トランザクションの更新に失敗しました");
    }

    // 関連データ取得
    const { data: enrichedTransaction, error: fetchError } =
      await supabaseClient
        .from("transactions")
        .select("*, sub_categories!inner(*), profiles!inner(*)")
        .eq("id", updatedTransaction[0].id)
        .single();

    console.log(enrichedTransaction);
    if (fetchError) {
      throw new Error("トランザクションの関連データの取得に失敗しました");
    }

    return new Response(
      JSON.stringify({ success: true, transaction: enrichedTransaction }),
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

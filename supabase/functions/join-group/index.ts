import {serve} from "https://deno.land/std@0.182.0/http/server.ts";
import {createClient} from "https://esm.sh/v135/@supabase/supabase-js@2.14.0/dist/module/index.js";
import {corsHeaders} from "../_shared/cors.ts";

console.log("Join group");

serve(async (request) => {
    if (request.method === "OPTIONS") {
        return new Response("ok", {headers: corsHeaders});
    }

    const data = await request.json();

    try {
        const supabaseClient = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
            {global: {headers: {Authorization: request.headers.get('Authorization')!}}}
        );

        // Get current user
        const {data: {user}, error: userError} = await supabaseClient.auth.getUser();
        if (userError || !user) throw new Error('再度ログインして実行してください');

        // Get user group
        const now = new Date();
        const {data: group, error: groupError} = await supabaseClient
            .from('user_groups')
            .select('*')
            .eq('invite_code', data.invite_code)
            .gte('invite_limit', now.toISOString()).single();

        if (!group) throw new Error('招待コードが違うか、有効期限が切れています');

        if (groupError) throw new Error(`サーバーエラー: ${groupError.message}`);

        // Count group members
        const {count, error: countError} = await supabaseClient
            .from('profiles')
            .select('*', {count: 'exact', head: true}) // Only return the count
            .eq('group_id', group.id);

        if (countError) throw new Error(`Profile count failed: ${countError.message}`);

        if (count != null && count >= 2) {
            throw new Error('グループの定員に達しています。1グループ2人までです');
        }

        // Add user to the group
        const updateResult = await supabaseClient
            .from('profiles')
            .update({
                group_id: group.id,
                invite_status: 'accepted',
                invited_at: now.toISOString(),
                updated_at: now.toISOString(),
            })
            .eq('id', user.id);

        if (updateResult.error) {
            throw new Error(`更新に失敗しました: ${updateResult.error.message}`);
        }

        return new Response(
            JSON.stringify({success: true}),
            {
                headers: {...corsHeaders, "Content-Type": "application/json"},
                status: 200
            }
        );
    } catch (error) {
        console.error(error);
        if (error instanceof Error) {
            return new Response(
                JSON.stringify({success: false, error: error.message}),
                {
                    headers: {...corsHeaders, "Content-Type": "application/json"},
                    status: 200
                }
            );
        } else {
            return new Response(
                JSON.stringify({success: false, error: 'Unknown error occurred'}),
                {
                    headers: {...corsHeaders, "Content-Type": "application/json"},
                    status: 200
                }
            );
        }
    }
});

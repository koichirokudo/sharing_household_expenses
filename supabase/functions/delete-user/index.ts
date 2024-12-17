import {serve} from 'https://deno.land/std@0.182.0/http/server.ts';
import {createClient} from 'https://esm.sh/@supabase/supabase-js@2.14.0';
import {corsHeaders} from '../_shared/cors.ts';

console.log("Delete user account function");

serve(async (request) => {
  // This is needed if you're planning to invoke your function from a browser.
  if (request.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Create instance of SupabaseClient
    const supabaseClient = createClient(
        Deno.env.get('SUPABASE_URL') ?? '',
        Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
        { global: { headers: { Authorization: request.headers.get('Authorization')! } } }
    );

    // Get current user
    const { data: { user }, error: userError } = await supabaseClient.auth.getUser();
    if (userError || !user) throw new Error('No user found for JWT!');

    // Get user profile (for avatar filename)
    const { data: profile, error: profileError } = await supabaseClient
        .from('profiles')  // Assuming profile information is stored in 'profiles' table
        .select('group_id, avatar_filename')
        .eq('id', user.id)
        .single();

    if (profileError) throw new Error('Error fetching user profile.');

    // 1. Delete avatar file if it exists
    if (profile?.avatar_filename) {
      const { error: avatarError } = await supabaseClient.storage
          .from('avatars')
          .remove([profile.avatar_filename]);

      if (avatarError) throw new Error('Error deleting avatar file.');
    }

    // 2. Delete user-related data (e.g., transaction history, settlements)
    await supabaseClient
        .from('transactions') // Assuming transactions are stored in 'transactions' table
        .delete()
        .eq('user_id', user.id);

    // 3. Optionally, delete other data such as payments, subscriptions, user group if last member
    // TODO: Add additional cleanup logic here
    const { data: userGroup, error: userGroupError } = await supabaseClient.from('user_groups').select('*', {count: 'exact'}).match({ id: profile?.group_id });
    if (userGroupError) throw new Error('Error fetching user group.');

    if (userGroup?.[0]?.exact === 1) {
      await supabaseClient.from('user_groups').delete().eq('id', profile?.group_id);
    }

    // 4. Delete user from authentication system
    const supabaseAdmin = createClient(
        Deno.env.get('SUPABASE_URL') ?? '',
        Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );
    await supabaseAdmin.auth.admin.deleteUser(user.id);

    // 5. Return success response
    return new Response(
        JSON.stringify({ success: true }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200,
        }
    );
  } catch (error) {
    // Log error and return failure response
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

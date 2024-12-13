import { serve } from 'https://deno.land/std@0.182.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.14.0';
import { corsHeaders } from '../_shared/cors.ts';

console.log("Delete user account function");

serve(async (request) => {

  // This is needed if you're planning to invoke your function from a browser.
  if (request.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    //Create instance of SupabaseClient
    const supabaseClient = createClient(
        Deno.env.get('SUPABASE_URL') ?? '',
        Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
        { global: { headers: { Authorization: request.headers.get('Authorization')! } } }
    );

    // Create a user object which contains the data we need to identify the user.id
    const {
      data: { user },
    } = await supabaseClient.auth.getUser()

    // Throw an error if there are any issues with identifying the users from the token
    if (!user) throw new Error('No user found for JWT!');

    // Create supabaseAdmin client which specifically uses the Service Role
    // Key in order to perform elevated administration actins
    const supabaseAdmin = createClient(
        Deno.env.get('SUPABASE_URL') ?? '',
        Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Call the deleteUser method on the supabaseAdmin client and pass the user.id
    await supabaseAdmin.auth.admin.deleteUser(user.id)

    // Return a response of the user which has been deleted
    return new Response(JSON.stringify({success: true}), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    });
  } catch (error) {
    // Return an error with the error message should it run in to any issues
    return new Response(JSON.stringify({ error: error}), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
});

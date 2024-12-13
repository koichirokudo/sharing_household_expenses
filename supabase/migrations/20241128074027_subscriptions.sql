DROP SEQUENCE IF EXISTS subscriptions_id_seq;
CREATE SEQUENCE subscriptions_id_seq;
CREATE TABLE subscriptions (
    id integer PRIMARY KEY DEFAULT nextval('subscriptions_id_seq'::regclass),
    profile_id uuid NOT NULL REFERENCES profiles(id),
    stripe_subscription_id VARCHAR(255),
    stripe_plan_id VARCHAR(255),
    plan_type TEXT CHECK (plan_type IN ('premium', 'basic')),
    status TEXT CHECK (status IN ('active', 'canceled', 'trialing')),
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE POLICY "Enable access to authenticated users only"
ON "public"."subscriptions"
TO public
USING (
    (auth.uid() IS NOT NULL)
);

CREATE INDEX "subscriptions_id_index" ON "public"."subscriptions" ("id");
CREATE INDEX "subscriptions_profile_id_index" ON "public"."subscriptions" ("profile_id");
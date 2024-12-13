DROP SEQUENCE IF EXISTS payments_id_seq;
CREATE SEQUENCE payments_id_seq;
CREATE TABLE payments (
    id integer PRIMARY KEY DEFAULT nextval('payments_id_seq'::regclass),
    profile_id uuid NOT NULL REFERENCES profiles(id),
    amount NUMERIC(10, 2) NOT NULL,
    payment_date TIMESTAMP WITH TIME ZONE NOT NULL,
    stripe_payment_id VARCHAR(255),
    payment_status TEXT CHECK (payment_status IN ('pending', 'success', 'failed')), -- 'pending', 'success', 'failed'
    subscription_id integer REFERENCES subscriptions(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE
);

CREATE POLICY "Enable access to authenticated users only"
ON "public"."payments"
TO public
USING (
    (auth.uid() IS NOT NULL)
);

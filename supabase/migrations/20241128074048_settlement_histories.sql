CREATE SEQUENCE settlement_histories_id_seq;
CREATE TABLE settlement_histories (
    id integer PRIMARY KEY DEFAULT nextval('settlement_histories_id_seq'::regclass),
    settlement_id integer NOT NULL REFERENCES settlements(id),
    change_type TEXT NOT NULL, -- 'add', 'remove'
    change_by uuid NOT NULL REFERENCES profiles(id),
    role TEXT NOT NULL, -- 'payer', 'payee'
    previous_amount NUMERIC(10, 2) NOT NULL DEFAULT 0,
    previous_date TIMESTAMP WITH TIME ZONE NOT NULL,
    change_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE POLICY "Enable access to authenticated users only"
ON "public"."settlement_histories"
TO public
USING (
    (auth.uid() IS NOT NULL)
);
DROP SEQUENCE IF EXISTS transaction_histories_id_seq;
CREATE SEQUENCE transaction_histories_id_seq;
CREATE TABLE transaction_histories (
    id integer PRIMARY KEY DEFAULT nextval('transaction_histories_id_seq'::regclass),
    transaction_id integer NOT NULL REFERENCES transactions(id),
    action TEXT NOT NULL, -- 'add', 'remove'
    change_by uuid NOT NULL REFERENCES profiles(id),
    previous_amount NUMERIC(10, 2) NOT NULL DEFAULT 0,
    previous_type TEXT NOT NULL, -- 'payer', 'payee'
    previous_category_id integer REFERENCES categories(id),
    previous_note TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

ALTER TABLE transaction_histories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable access to authenticated users only"
ON "public"."transaction_histories"
TO public
USING (
    (auth.uid() IS NOT NULL)
);

CREATE INDEX "transaction_histories_transaction_id_index" ON "public"."transaction_histories" ("transaction_id");
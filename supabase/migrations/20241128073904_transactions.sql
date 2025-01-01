DROP SEQUENCE IF EXISTS transactions_id_seq;
CREATE SEQUENCE transactions_id_seq;
CREATE TABLE transactions (
    id integer PRIMARY KEY DEFAULT nextval('transactions_id_seq'::regclass),
    profile_id uuid NOT NULL REFERENCES profiles(id),
    group_id uuid NOT NULL REFERENCES user_groups(id),
    visibility TEXT NOT NULL CHECK (visibility IN ('shared', 'private')),
    settlement_id integer REFERENCES settlements(id),
    category_id integer NOT NULL REFERENCES categories(id),
    name TEXT NOT NULL,
    date TIMESTAMP WITH TIME ZONE NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('income', 'expense')), -- 'income', 'expense'
    amount NUMERIC(10, 2) NOT NULL DEFAULT 0,
    share BOOLEAN NOT NULL DEFAULT false,
    note TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable access to authenticated users only"
ON "public"."transactions"
TO public
USING (
    (auth.uid() IS NOT NULL)
);

CREATE INDEX "transactions_id_index" ON "public"."transactions" ("id");
CREATE INDEX "transactions_group_id_index" ON "public"."transactions" ("group_id");
CREATE INDEX "transactions_profile_id_index" ON "public"."transactions" ("profile_id");
CREATE INDEX "transactions_settlement_id_index" ON "public"."transactions" ("settlement_id");
CREATE INDEX "transactions_category_id_index" ON "public"."transactions" ("category_id");
CREATE INDEX "transactions_visibility_index" ON "public"."transactions" ("visibility");
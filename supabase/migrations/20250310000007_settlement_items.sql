DROP SEQUENCE IF EXISTS settlement_items_id_seq;
CREATE SEQUENCE settlement_items_id_seq;
CREATE TABLE settlement_items
(
    id         integer PRIMARY KEY DEFAULT nextval('settlement_items_id_seq'::regclass),
    settlement_id integer NOT NULL REFERENCES settlements(id),
    profile_id uuid NOT NULL REFERENCES profiles (id),
    role TEXT NOT NULL CHECK (role IN ('payer', 'payee', 'self', 'even')), -- 'payer', 'payee', 'self', 'even'
    amount NUMERIC(10, 2) NOT NULL DEFAULT 0,
    percentage NUMERIC(10, 2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

ALTER TABLE settlement_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable access to authenticated users only"
ON "public"."settlement_items"
TO public
USING (
    (auth.uid() IS NOT NULL)
);

CREATE INDEX "settlement_items_id_index" ON "public"."settlement_items" ("id");
CREATE INDEX "settlement_items_settlement_id_index" ON "public"."settlement_items" ("settlement_id");
CREATE INDEX "settlement_items_profile_id_index" ON "public"."settlement_items" ("profile_id");

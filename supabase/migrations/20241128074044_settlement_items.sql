DROP SEQUENCE IF EXISTS participants_id_seq;
CREATE SEQUENCE participants_id_seq;
CREATE TABLE settlement_items
(
    id integer PRIMARY KEY DEFAULT nextval('participants_id_seq'::regclass),
    settlement_id integer NOT NULL REFERENCES settlements(id),
    profile_id TEXT NOT NULL REFERENCES profiles (id),
    role TEXT NOT NULL CHECK (role IN ('payer', 'payee', 'self')), -- 'payer', 'payee', 'self'
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
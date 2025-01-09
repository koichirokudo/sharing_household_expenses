DROP SEQUENCE IF EXISTS settlements_id_seq;
CREATE SEQUENCE settlements_id_seq;
CREATE TABLE settlements (
    id integer PRIMARY KEY DEFAULT nextval('settlements_id_seq'::regclass),
    group_id uuid NOT NULL REFERENCES user_groups(id),
    visibility TEXT NOT NULL CHECK (visibility IN ('shared', 'private')),
    settlement_date TEXT NOT NULL,
    income_total_amount  NUMERIC(10, 2) NOT NULL DEFAULT 0,
    expense_total_amount NUMERIC(10, 2) NOT NULL DEFAULT 0,
    amount_per_person NUMERIC(10, 2) NOT NULL DEFAULT 0,
    status TEXT CHECK(status IN ('completed', 'canceled', 'pending')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

ALTER TABLE settlements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable access to authenticated users only"
ON "public"."settlements"
TO public
USING (
    (auth.uid() IS NOT NULL)
);

CREATE INDEX "settlements_id_index" ON "public"."settlements" ("id");
CREATE INDEX "settlements_group_id_index" ON "public"."settlements" ("group_id");
CREATE INDEX "settlements_visibility_index" ON "public"."settlements" ("visibility");

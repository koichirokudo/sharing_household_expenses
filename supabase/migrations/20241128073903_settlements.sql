DROP SEQUENCE IF EXISTS settlements_id_seq;
CREATE SEQUENCE settlements_id_seq;
CREATE TABLE settlements (
    id integer PRIMARY KEY DEFAULT nextval('settlements_id_seq'::regclass),
    group_id uuid NOT NULL REFERENCES user_groups(id),
    settlement_date TIMESTAMP WITH TIME ZONE NOT NULL,
    total_amount NUMERIC(10, 2) NOT NULL DEFAULT 0,
    status TEXT CHECK(status IN ('completed', 'canceled', 'pending')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE POLICY "Enable access to authenticated users only"
ON "public"."settlements"
TO public
USING (
    (auth.uid() IS NOT NULL)
);

CREATE INDEX "settlements_id_index" ON "public"."settlements" ("id");
CREATE INDEX "settlements_group_id_index" ON "public"."settlements" ("group_id");
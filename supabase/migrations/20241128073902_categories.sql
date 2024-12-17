DROP SEQUENCE IF EXISTS categories_id_seq;
CREATE SEQUENCE categories_id_seq;
CREATE TABLE categories (
    id integer PRIMARY KEY DEFAULT nextval('categories_id_seq'::regclass),
    group_id uuid REFERENCES user_groups(id),
    type TEXT NOT NULL,
    name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable access to authenticated users only"
ON "public"."categories"
TO public
USING (
    (auth.uid() IS NOT NULL)
);

CREATE INDEX "categories_group_id_index" ON "public"."categories" ("group_id");
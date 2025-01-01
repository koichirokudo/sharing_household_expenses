DROP SEQUENCE IF EXISTS sub_categories_id_seq;
CREATE SEQUENCE sub_categories_id_seq;
CREATE TABLE sub_categories
(
    id          integer PRIMARY KEY      DEFAULT nextval('sub_categories_id_seq'::regclass),
    category_id integer REFERENCES categories (id),
    group_id    uuid REFERENCES user_groups (id),
    type        TEXT                                   NOT NULL,
    name        TEXT                                   NOT NULL,
    created_at  TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    updated_at  TIMESTAMP WITH TIME ZONE               NOT NULL
);

ALTER TABLE sub_categories ENABLE ROW LEVEL SECURITY;

CREATE
POLICY "Enable access to authenticated users only"
ON "public"."sub_categories"
TO public
USING (
    (auth.uid() IS NOT NULL)
);

CREATE INDEX "sub_categories_categories_id_index" ON "public"."categories" ("category_id");
CREATE INDEX "sub_categories_group_id_index" ON "public"."sub_categories" ("group_id");

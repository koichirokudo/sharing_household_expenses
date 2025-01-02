DROP SEQUENCE IF EXISTS sub_categories_id_seq;
CREATE SEQUENCE sub_categories_id_seq START WITH 5001;
CREATE TABLE sub_categories
(
    id          integer PRIMARY KEY      DEFAULT nextval('sub_categories_id_seq'::regclass),
    parent_id integer NOT NULL REFERENCES categories (id) ON DELETE CASCADE,
    group_id    uuid REFERENCES user_groups (id),
    name        TEXT                                   NOT NULL,
    created_at  TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    updated_at  TIMESTAMP WITH TIME ZONE               NOT NULL
);

ALTER TABLE sub_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE sub_categories
    ADD CONSTRAINT unique_subcategory_name UNIQUE (parent_id, name);

CREATE
POLICY "Enable access to authenticated users only"
ON "public"."sub_categories"
TO public
USING (
    (auth.uid() IS NOT NULL)
);

CREATE UNIQUE INDEX sub_category_unique_name ON sub_categories (parent_id, name);
CREATE INDEX "sub_categories_categories_id_index" ON "public"."sub_categories" ("parent_id");
CREATE INDEX "sub_categories_group_id_index" ON "public"."sub_categories" ("group_id");

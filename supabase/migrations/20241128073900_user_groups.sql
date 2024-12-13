CREATE TABLE user_groups (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    group_name TEXT NOT NULL,
    slug TEXT NOT NULL,
    invite_code TEXT NOT NULL,
    invite_limit TIMESTAMP WITH TIME ZONE,
    start_day integer NOT NULL DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE POLICY "Enable access to authenticated users only"
ON "public"."user_groups"
TO public
USING (
    (auth.uid() IS NOT NULL)
);

CREATE INDEX "user_groups_id_index" ON "public"."user_groups" ("id");

DROP SEQUENCE IF EXISTS group_name_seq;

CREATE SEQUENCE group_name_seq START 1 INCREMENT BY 1;

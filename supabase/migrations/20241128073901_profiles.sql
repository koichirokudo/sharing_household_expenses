CREATE TABLE profiles (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id uuid NOT NULL REFERENCES user_groups(id),
    username TEXT NOT NULL,
    avatar_url TEXT,
    invite_status TEXT CHECK (invite_status IN ('pending', 'accepted', 'rejected')),
    invited_at TIMESTAMP WITH TIME ZONE,
    cancel BOOLEAN DEFAULT FALSE,
    cancel_reason TEXT CHECK (cancel_reason IN (
        'Expensive', -- 料金が高い
        'Features provided were not needed', -- 提供される機能が不要だった
        'It was difficult to use', -- 利用方法が難しかった
        'Too many bug', -- バグが多い
        'Dissatisfied with performance' -- パフォーマンスに不満
        'Provider service' -- 代わりのサービスを見つけた
        'Temporary use' -- 一時的に利用したかっただけ
        'Privacy and security concerns' -- プライバシーとセキュリティの懸念
        'Others' -- その他（自由記入欄）
    )) DEFAULT NULL,
    canceled_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE POLICY "Enable access to authenticated users only"
ON "public"."profiles"
TO public
USING (
    (auth.uid() IS NOT NULL)
);

create or replace function public.handle_new_user()
returns trigger as $$
declare
    group_id UUID;
    group_name text;
    slug text;
    init_invite_code text;
    begin
        -- 招待コードがない場合は、ユーザーグループを自動作成して、ユーザーをそのグループに属させる
        if (new.raw_user_meta_data->>'invite_code' IS NULL OR new.raw_user_meta_data->>'invite_code' = '') then
            -- group_name と slug を group_ + シーケンス値として設定
            group_name := 'group_' || LPAD(nextval('public.group_name_seq')::text, 6, '0');
            slug := group_name;
            -- invite_code を生成して設定
            init_invite_code := substring(replace(gen_random_uuid()::text, '-', ''), 1, 8);
            insert into public.user_groups(group_name, slug, invite_code, updated_at) values(group_name, slug, init_invite_code, now()) returning id into group_id;
            -- public.profiles にコピーする
            insert into public.profiles(id, username, group_id, invite_status, invited_at, updated_at) values(new.id, new.raw_user_meta_data->>'username', group_id, 'accepted', now(), now());
        else
            -- 招待コードがある場合、既存ユーザーグループの invite_code にマッチした user_group.id を取得
            select id into group_id from public.user_groups where public.user_groups.invite_code = new.raw_user_meta_data->>'invite_code' limit 1;
            -- public.profiles にコピーする
            insert into public.profiles(id, username, group_id, invite_status, invited_at, updated_at) values(new.id, new.raw_user_meta_data->>'username', group_id, 'accepted', now(), now());
        end if;

        return new;
    end;
$$ language plpgsql security definer;

-- ユーザー作成時に`handle_new_user`を呼ぶためのトリガーを定義
create trigger on_auth_user_created
after insert on auth.users for each row
execute function handle_new_user ();

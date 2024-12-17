CREATE TABLE profiles (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id uuid REFERENCES user_groups (id),
    username TEXT NOT NULL,
    avatar_url TEXT,
    avatar_filename TEXT,
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

create
policy "Users can view their own profile and group profiles" on profiles
for
select using (true);

create policy "Users can insert their own profile." on profiles
    for insert with check ((select auth.uid()) = id);

create policy "Users can update own profile." on profiles
    for update using ((select auth.uid()) = id);

create or replace function public.handle_new_user()
returns trigger as $$
declare
    begin
        -- public.profiles にコピーする
insert into public.profiles(id, username, invite_status, invited_at, updated_at)
values (new.id, new.raw_user_meta_data ->>'username', 'pending', now(), now());
        return new;
    end;
$$ language plpgsql security definer;

-- ユーザー作成時に`handle_new_user`を呼ぶためのトリガーを定義
create trigger on_auth_user_created
after insert on auth.users for each row
execute function handle_new_user ();

create policy "Avatar images are publicly accessible." on storage.objects
  for select using (bucket_id = 'avatars');

create policy "Anyone can upload an avatar." on storage.objects
  for insert with check (bucket_id = 'avatars');

create policy "Anyone can update their own avatar." on storage.objects
  for update using ((select auth.uid()) = owner) with check (bucket_id = 'avatars');

create policy "Anyone can delete an avatar." on storage.objects
  for delete using (auth.uid() = owner AND bucket_id = 'avatars');

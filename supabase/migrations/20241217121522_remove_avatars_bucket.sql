-- TODO: 本番環境では実行してはいけない
DELETE
FROM storage.buckets
WHERE id = 'avatars';

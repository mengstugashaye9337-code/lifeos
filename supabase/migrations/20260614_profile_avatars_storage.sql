-- Profile avatar storage setup for Supabase
-- Bucket: avatars
-- Path convention: {user_id}/profile.jpg within the bucket

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do update
set public = excluded.public;

alter table storage.objects enable row level security;

drop policy if exists "Public read access for avatars" on storage.objects;
drop policy if exists "Authenticated users can upload their own avatar" on storage.objects;
drop policy if exists "Authenticated users can update their own avatar" on storage.objects;
drop policy if exists "Authenticated users can delete their own avatar" on storage.objects;

create policy "Public read access for avatars"
on storage.objects
for select
to public
using (
  bucket_id = 'avatars'
);

create policy "Authenticated users can upload their own avatar"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'avatars'
  and name = auth.uid()::text || '/profile.jpg'
);

create policy "Authenticated users can update their own avatar"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'avatars'
  and name = auth.uid()::text || '/profile.jpg'
)
with check (
  bucket_id = 'avatars'
  and name = auth.uid()::text || '/profile.jpg'
);

create policy "Authenticated users can delete their own avatar"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'avatars'
  and name = auth.uid()::text || '/profile.jpg'
);
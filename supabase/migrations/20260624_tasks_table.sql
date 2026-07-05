-- Session 3: tasks table + RLS for authenticated users

create table if not exists tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  title text not null,
  description text,
  due_date timestamp with time zone,
  is_completed boolean not null default false,
  priority integer not null default 1,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  deleted_at timestamp with time zone,
  constraint tasks_user_fk foreign key (user_id) references auth.users (id) on delete cascade
);

create index if not exists idx_tasks_user_id_updated_at on tasks(user_id, updated_at desc);
create index if not exists idx_tasks_user_id_deleted_at on tasks(user_id, deleted_at);

create or replace function set_tasks_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_tasks_set_updated_at on tasks;
create trigger trg_tasks_set_updated_at
before update on tasks
for each row
execute function set_tasks_updated_at();

alter table tasks enable row level security;

drop policy if exists "Authenticated users can select their own tasks" on tasks;
drop policy if exists "Authenticated users can insert their own tasks" on tasks;
drop policy if exists "Authenticated users can update their own tasks" on tasks;
drop policy if exists "Authenticated users can delete their own tasks" on tasks;

create policy "Authenticated users can select their own tasks"
  on tasks
  for select
  to authenticated
  using (user_id = auth.uid()::uuid);

create policy "Authenticated users can insert their own tasks"
  on tasks
  for insert
  to authenticated
  with check (user_id = auth.uid()::uuid);

create policy "Authenticated users can update their own tasks"
  on tasks
  for update
  to authenticated
  using (user_id = auth.uid()::uuid)
  with check (user_id = auth.uid()::uuid);

create policy "Authenticated users can delete their own tasks"
  on tasks
  for delete
  to authenticated
  using (user_id = auth.uid()::uuid);

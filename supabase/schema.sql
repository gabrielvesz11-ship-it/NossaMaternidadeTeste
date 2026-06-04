create extension if not exists "pgcrypto";

create table if not exists public.profiles (
  id uuid primary key default gen_random_uuid(),
  anonymous_user_id text not null,
  name text not null,
  due_date date,
  is_first_pregnancy boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.chat_messages (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  role text not null check (role in ('user', 'assistant')),
  content text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.daily_usage (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  date date not null,
  nathia_message_count integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, date)
);

create table if not exists public.weekly_journal_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  pregnancy_week integer not null check (pregnancy_week between 1 and 40),
  mood text not null,
  symptoms text[] not null default '{}',
  note text not null default '',
  local_photo_uri text,
  remote_photo_url text,
  sync_status text not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, pregnancy_week)
);

create table if not exists public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  revenuecat_customer_id text not null,
  entitlement text not null default 'premium',
  status text not null,
  expires_at timestamptz,
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.chat_messages enable row level security;
alter table public.daily_usage enable row level security;
alter table public.weekly_journal_entries enable row level security;
alter table public.subscriptions enable row level security;

create or replace function public.profile_belongs_to_current_user(profile_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles
    where id = profile_id
      and anonymous_user_id = auth.uid()::text
  );
$$;

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own"
on public.profiles for select
using (anonymous_user_id = auth.uid()::text);

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own"
on public.profiles for insert
with check (anonymous_user_id = auth.uid()::text);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
on public.profiles for update
using (anonymous_user_id = auth.uid()::text)
with check (anonymous_user_id = auth.uid()::text);

drop policy if exists "chat_messages_own" on public.chat_messages;
create policy "chat_messages_own"
on public.chat_messages for all
using (public.profile_belongs_to_current_user(user_id))
with check (public.profile_belongs_to_current_user(user_id));

drop policy if exists "daily_usage_own" on public.daily_usage;
create policy "daily_usage_own"
on public.daily_usage for all
using (public.profile_belongs_to_current_user(user_id))
with check (public.profile_belongs_to_current_user(user_id));

drop policy if exists "weekly_journal_entries_own" on public.weekly_journal_entries;
create policy "weekly_journal_entries_own"
on public.weekly_journal_entries for all
using (public.profile_belongs_to_current_user(user_id))
with check (public.profile_belongs_to_current_user(user_id));

drop policy if exists "subscriptions_own" on public.subscriptions;
create policy "subscriptions_own"
on public.subscriptions for all
using (public.profile_belongs_to_current_user(user_id))
with check (public.profile_belongs_to_current_user(user_id));

insert into storage.buckets (id, name, public)
values ('journal-photos', 'journal-photos', false)
on conflict (id) do nothing;

drop policy if exists "journal_photos_select_own" on storage.objects;
create policy "journal_photos_select_own"
on storage.objects for select
using (
  bucket_id = 'journal-photos'
  and split_part(name, '/', 1) = auth.uid()::text
);

drop policy if exists "journal_photos_insert_own" on storage.objects;
create policy "journal_photos_insert_own"
on storage.objects for insert
with check (
  bucket_id = 'journal-photos'
  and split_part(name, '/', 1) = auth.uid()::text
);

drop policy if exists "journal_photos_update_own" on storage.objects;
create policy "journal_photos_update_own"
on storage.objects for update
using (
  bucket_id = 'journal-photos'
  and split_part(name, '/', 1) = auth.uid()::text
)
with check (
  bucket_id = 'journal-photos'
  and split_part(name, '/', 1) = auth.uid()::text
);

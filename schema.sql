-- Zélum'Rai Studio V4 database
create extension if not exists "pgcrypto";

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  role text not null default 'artist' check (role in ('artist','admin')),
  created_at timestamptz not null default now()
);

create table if not exists public.tracks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  artist_name text,
  storage_path text not null,
  is_public boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.bookings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  service text not null,
  date date not null,
  time time not null,
  notes text,
  status text not null default 'pending' check (status in ('pending','confirmed','cancelled')),
  created_at timestamptz not null default now()
);

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  booking_id uuid references public.bookings(id) on delete set null,
  stripe_session_id text unique,
  amount integer not null,
  currency text not null default 'usd',
  status text not null default 'pending',
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.tracks enable row level security;
alter table public.bookings enable row level security;
alter table public.payments enable row level security;

create or replace function public.is_admin()
returns boolean language sql security definer set search_path=public
as $$ select exists(select 1 from public.profiles where id=auth.uid() and role='admin'); $$;

create policy "profiles read own/admin" on public.profiles for select using (id=auth.uid() or public.is_admin());
create policy "profiles insert own" on public.profiles for insert with check (id=auth.uid());

create policy "tracks public/own/admin read" on public.tracks for select using (is_public=true or user_id=auth.uid() or public.is_admin());
create policy "tracks own insert" on public.tracks for insert with check (user_id=auth.uid());
create policy "tracks own update" on public.tracks for update using (user_id=auth.uid() or public.is_admin()) with check (user_id=auth.uid() or public.is_admin());
create policy "tracks own delete" on public.tracks for delete using (user_id=auth.uid() or public.is_admin());

create policy "bookings own/admin read" on public.bookings for select using (user_id=auth.uid() or public.is_admin());
create policy "bookings own insert" on public.bookings for insert with check (user_id=auth.uid());
create policy "bookings admin update" on public.bookings for update using (public.is_admin()) with check (public.is_admin());

create policy "payments own/admin read" on public.payments for select using (user_id=auth.uid() or public.is_admin());

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path=public
as $$
begin
  insert into public.profiles(id,display_name)
  values(new.id,coalesce(new.raw_user_meta_data->>'display_name',split_part(new.email,'@',1)))
  on conflict(id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

-- Storage:
-- Create a PUBLIC bucket called "music".
-- Public read is required by /music and the audio player.
-- Authenticated users should only upload to folders named with their auth.uid().
-- Example path: USER_UUID/track-name.mp3

-- Promote your own account to admin after signup:
-- update public.profiles set role='admin' where id='YOUR-USER-UUID';
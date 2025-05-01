-- Global sharer identity (used across businesses and campaigns)
create table if not exists sharer (
  id uuid primary key default gen_random_uuid(),

  external_user_id text,
  device_fingerprint text,
  user_agent text,
  created_at timestamptz default now(),

  email text check (
    email is null or email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'
  ),
  phone text, -- E.164 normalized
  active boolean default true
);

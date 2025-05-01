-- Auth record for merchants (non-consumer)
create table if not exists auth_identity (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references business(id) on delete cascade,

  auth_email text not null check (
    auth_email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'
  ),
  auth_phone text not null,

  login_method text not null check (
    login_method in ('password', 'magic_link')
  ),

  magic_link_enabled boolean not null default false,
  proof_of_business_submitted boolean not null default false,

  created_at timestamptz default now()
);
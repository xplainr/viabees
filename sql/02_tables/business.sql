-- Core merchant profile
create table if not exists business (
  id uuid primary key default gen_random_uuid(),

  name text not null check (char_length(name) >= 1),
  category text not null check (char_length(category) >= 1),

  contact_phone text not null,
  contact_email text not null check (
    contact_email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'
  ),

  public_contact_uri text,

  street text not null check (char_length(street) >= 1),
  city text not null check (char_length(city) >= 1),
  postal_code text not null check (char_length(postal_code) >= 1),
  country text not null check (char_length(country) >= 1),
  region text,

  registered_at timestamptz not null default now(),
  active boolean default true
);

-- Many-to-many link between sharers and businesses
create table if not exists sharer_business (
  sharer_id uuid references sharer(id) on delete cascade,
  business_id uuid references business(id) on delete cascade,

  first_seen_at timestamptz default now(),
  last_seen_at timestamptz,
  consent_to_retargeting boolean default false,

  primary key (sharer_id, business_id)
);

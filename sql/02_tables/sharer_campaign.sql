-- Tracks share activity between sharers and campaigns
create table if not exists sharer_campaign (
  sharer_id uuid references sharer(id) on delete cascade,
  campaign_id uuid references campaign(id) on delete cascade,

  first_shared_at timestamptz default now(),
  shares_count integer default 1,

  primary key (sharer_id, campaign_id)
);

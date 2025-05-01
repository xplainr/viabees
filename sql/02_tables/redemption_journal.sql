-- Append-only journal of all claim redemptions
create table if not exists redemption_journal (
  id uuid primary key default gen_random_uuid(),

  claim_token text not null,  -- Opaque, deterministic token
  business_id uuid not null references business(id),
  campaign_id uuid not null references campaign(id),
  sharer_id uuid,             -- Optional: attribution if known

  redeemed_at timestamptz not null default now(),  -- Server-side timestamp
  ip_address text,
  user_agent text,

  status text not null check (
    status in ('valid', 'redeemed', 'expired', 'invalid')
  ),

  event jsonb  -- Optional: contextual data like geolocation, device metadata, etc.
);

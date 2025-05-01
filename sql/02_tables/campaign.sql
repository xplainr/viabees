-- Campaigns = shareable offers under a business
create table if not exists campaign (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references business(id) on delete cascade,

  recipient_offer_text text not null check (char_length(recipient_offer_text) >= 5),
  sharer_offer_text text check (
    sharer_offer_text is null or char_length(sharer_offer_text) >= 5
  ),
  terms_and_conditions text check (
    terms_and_conditions is null or char_length(terms_and_conditions) <= 500
  ),

  offer_type text check (
    offer_type in ('Discount Percentage', 'Flat Discount', 'Free Item', 'Other') or offer_type is null
  ),

  valid_from timestamptz not null,
  valid_until timestamptz not null,
  check (valid_until > valid_from),

  redemption_limit integer,
  created_at timestamptz default now(),
  active boolean default true
);
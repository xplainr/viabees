-- Create a demo business
insert into business (
  id, name, category,
  contact_phone, contact_email, public_contact_uri,
  street, city, postal_code, country, region
)
values (
  '00000000-0000-0000-0000-000000000001',
  'Demo Coffee Co.',
  'Cafe',
  '+1 (555) 123-4567',
  'owner@demo-coffee.com',
  'https://demo-coffee.com',
  '123 Roast St.',
  'Beanville',
  '98765',
  'USA',
  'WA'
);

-- Create an auth identity for the business
insert into auth_identity (
  id, business_id, auth_email, auth_phone, login_method, magic_link_enabled, proof_of_business_submitted
)
values (
  '00000000-0000-0000-0000-000000000101',
  '00000000-0000-0000-0000-000000000001',
  'owner@demo-coffee.com',
  '+1 (555) 123-4567',
  'magic_link',
  true,
  true
);

-- Create a campaign for that business
insert into campaign (
  id, business_id,
  recipient_offer_text, sharer_offer_text, terms_and_conditions,
  offer_type, valid_from, valid_until, redemption_limit
)
values (
  '00000000-0000-0000-0000-000000000201',
  '00000000-0000-0000-0000-000000000001',
  'Get a free coffee with your first purchase!',
  'Invite friends and earn rewards.',
  'One per customer. Cannot be combined with other offers.',
  'Free Item',
  now() - interval '1 day',
  now() + interval '30 days',
  1000
);

-- Create a test sharer
insert into sharer (
  id, external_user_id, device_fingerprint, user_agent, email, phone
)
values (
  '00000000-0000-0000-0000-000000000301',
  'ext-abc-123',
  'fp-demo-device',
  'Mozilla/5.0 (TestAgent)',
  'sharer@example.com',
  '+1 (555) 987-6543'
);

-- Link sharer to business
insert into sharer_business (
  sharer_id, business_id, consent_to_retargeting
)
values (
  '00000000-0000-0000-0000-000000000301',
  '00000000-0000-0000-0000-000000000001',
  true
);

-- Link sharer to campaign
insert into sharer_campaign (
  sharer_id, campaign_id, shares_count
)
values (
  '00000000-0000-0000-0000-000000000301',
  '00000000-0000-0000-0000-000000000201',
  1
);

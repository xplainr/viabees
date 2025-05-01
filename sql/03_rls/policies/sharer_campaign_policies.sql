-- Allow SELECT on sharer-campaign only if campaign belongs to current business
create policy "select: sharer-campaign for current business"
on sharer_campaign
for select
using (
  campaign_id in (
    select id from campaign
    where business_id::text = current_setting('app.current_business_id', true)
  )
);

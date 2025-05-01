-- Allow SELECT only for campaigns belonging to current business
create policy "select: campaigns in current business"
on campaign
for select
using (
  business_id::text = current_setting('app.current_business_id', true)
);

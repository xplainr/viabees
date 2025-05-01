-- Allow SELECT only for sharer-business links in current business
create policy "select: sharer-business for current business"
on sharer_business
for select
using (
  business_id::text = current_setting('app.current_business_id', true)
);

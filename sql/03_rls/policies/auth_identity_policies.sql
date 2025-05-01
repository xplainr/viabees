-- Allow SELECT only on auth_identity belonging to current business
create policy "select: auth identity for current business"
on auth_identity
for select
using (
  business_id::text = current_setting('app.current_business_id', true)
);

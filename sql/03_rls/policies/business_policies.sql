-- Allow SELECT only on the business the current session is scoped to
create policy "select: own business"
on business
for select
using (
  id::text = current_setting('app.current_business_id', true)
);

-- Allow SELECT only for redemptions tied to current business context
create policy "select: redemptions for current business"
on redemption_journal
for select
using (
  business_id::text = current_setting('app.current_business_id', true)
);

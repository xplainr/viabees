create or replace function insert_redemption(
  _claim_token text,
  _business_id uuid,
  _campaign_id uuid,
  _sharer_id uuid,
  _status text,
  _ip_address text,
  _user_agent text,
  _event jsonb default '{}'
)
returns void
language plpgsql
as $$
declare
  _business_id_text text;
begin
  _business_id_text := _business_id::text;
  set local app.current_business_id = _business_id_text;

  insert into redemption_journal (
    claim_token,
    business_id,
    campaign_id,
    sharer_id,
    status,
    ip_address,
    user_agent,
    event
  )
  values (
    _claim_token,
    _business_id,
    _campaign_id,
    _sharer_id,
    _status,
    _ip_address,
    _user_agent,
    _event
  );
end;
$$;

-- Enable Row-Level Security for all tenant-partitioned tables

alter table business enable row level security;
alter table campaign enable row level security;
alter table auth_identity enable row level security;
alter table sharer enable row level security;
alter table sharer_business enable row level security;
alter table sharer_campaign enable row level security;
alter table redemption_journal enable row level security;

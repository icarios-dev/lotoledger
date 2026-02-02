begin;
set role app_loto_owner;

create or replace function api.system__ready()
returns boolean
language sql
security definer
set search_path = app, pg_temp
as $$
	select true;
$$;

reset role;
commit;

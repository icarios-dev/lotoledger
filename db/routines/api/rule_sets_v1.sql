begin;
set role app_loto_owner;

create or replace function api.rule_sets_v1()
returns jsonb
language sql
stable
security definer
set search_path = api, app, pg_temp
as $$
	select rule_sets from api.rule_sets_v1_json;
$$;

reset role;
commit;

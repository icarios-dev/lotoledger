begin;
set role app_loto_owner;

create or replace function api.rulesets()
returns table (rule_set app.rule_set)
language sql
stable
security definer
set search_path = api, app, pg_temp
as $$
	select code as rule_set
	from api.rule_sets_v1
	order by code;
$$;

comment on function api.rulesets() is
'DEPRECATED: use api.rule_sets_v1 view instead.';

reset role;
commit;

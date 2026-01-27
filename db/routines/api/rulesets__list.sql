begin;
set role app_loto_owner;

create or replace function api.rulesets__list()
	returns table (rule_set text)
	language sql
	security definer
	set search_path = app, pg_temp
	as $$
	select
		distinct d.rule_set
	from
		app.draws as d
	order
		by d.rule_set;
$$;

revoke all on function api.list_rulesets() from public;
grant execute on function api.list_rulesets() to app_loto_user; -- ton rôle applicatif

reset role;
commit;

begin;
set role app_loto_owner;

create or replace function api.rulesets()
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

reset role;
commit;

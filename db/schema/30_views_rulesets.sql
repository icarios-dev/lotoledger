begin;
set role app_loto_owner;

create or replace view api.rule_sets_v1 as
select
	rs.code,
	1  as main_min,
	app.ruleset_main_max(rs.code)   as main_max,
	app.expected_main_count(rs.code) as main_size,
	app.expected_bonus_type(rs.code) as bonus_type,
	1  as bonus_min,
	app.ruleset_bonus_max(rs.code)  as bonus_max,
	app.ruleset_date_start(rs.code) as date_start,
	app.ruleset_date_end(rs.code)   as date_end
from unnest(enum_range(null::app.rule_set)) as rs(code);

revoke all on api.rule_sets_v1 from app_loto_user;

create or replace view api.rule_sets_v1_json as
select jsonb_agg(
	jsonb_build_object(
		'code', code,
		'main_min', main_min,
		'main_max', main_max,
		'main_size', main_size,
		'bonus_type', bonus_type,
		'bonus_min', bonus_min,
		'bonus_max', bonus_max,
		'date_start', date_start,
		'date_end', date_end
	)
	order by code
) as rule_sets
from api.rule_sets_v1;

revoke all on api.rule_sets_v1_json from app_loto_user;

reset role;
commit;

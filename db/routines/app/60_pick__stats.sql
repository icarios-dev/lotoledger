begin;
set role app_loto_owner;

create or replace function app.pick_stats(p_pick app.main_num[])
returns table (
	total_draws int,
	occurrences int,
	pct_of_draws numeric,
	draws jsonb
)
language sql
stable
as $$
with
	total as (
		select count(*)::int as total_draws
		from app.draws
	),
	hits as (
		select * from app.pick_hits(p_pick)
	)
select
	(select total_draws from total),
	count(*)::int,
	round(100.0 * count(*) / nullif((select total_draws from total), 0), 6),
	jsonb_agg(
		jsonb_build_object(
			'date', draw_date,
			'main', main_sorted,
			'bonus', bonus_value
		)
		order by draw_date
	)
from hits;
$$;

reset role;
commit;

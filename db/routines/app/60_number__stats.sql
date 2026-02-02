begin;
set role app_loto_owner;

create or replace function app.number_stats(p_pick app.main_num[])
returns table (
	num app.main_num,
	occurrences int,
	pct_of_draws numeric,
	first_seen date,
	last_seen date
)
language sql
stable
as $$
with total as (
	select count(*)::numeric as total_draws
	from app.draws
)
select
	n as num,
	count(*)::int as occurrences,
	round(100.0 * count(*) / nullif((select total_draws from total), 0), 6) as pct_of_draws,
	min(d.draw_date) as first_seen,
	max(d.draw_date) as last_seen
from unnest(p_pick) as n
join app.draws d
	on d.main_sorted @> array[n]::app.main_num[]
group by n
order by n;
$$;

reset role;
commit;

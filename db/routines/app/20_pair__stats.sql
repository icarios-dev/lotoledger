begin;
set role app_loto_owner;

create or replace function app.pair_stats(p_pick app.main_num[])
returns table (
	a app.main_num,
	b app.main_num,
	occurrences int,
	pct_of_draws numeric
)
language sql
stable
as $$
with
	total as (
		select count(*)::numeric as total_draws
		from app.draws
	),
	nums as (
		select unnest(p_pick) as n
	),
	pairs as (
		select n1.n as a, n2.n as b
		from nums n1
		join nums n2 on n1.n < n2.n   -- évite doublons et (a,a)
	)
select
	p.a,
	p.b,
	count(*)::int as occurrences,
	round(100.0 * count(*) / nullif((select total_draws from total), 0), 6) as pct_of_draws
from pairs p
join app.draws d
	on d.main_sorted @> array[p.a, p.b]::app.main_num[]
group by p.a, p.b
order by p.a, p.b;
$$;

reset role;
commit;

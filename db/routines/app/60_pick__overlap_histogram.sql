begin;
set role app_loto_owner;

create or replace function app.pick_overlap_histogram(p_pick app.main_num[])
returns table (
	overlap int,
	occurrences int,
	pct_of_draws numeric
)
language sql
stable
as $$
with
  total as (select count(*)::numeric as total_draws from app.draws),
  per_draw as (
    select
      cardinality(
        (select array_agg(x) from (
           select unnest(d.main_sorted) as x
           intersect
           select unnest(p_pick) as x
        ) s)
      ) as overlap
    from app.draws d
  )
select
	overlap,
	count(*)::int as occurrences,
	round(100.0 * count(*) / nullif((select total_draws from total), 0), 6) as pct_of_draws
from per_draw
group by overlap
order by overlap;
$$;

reset role;
commit;

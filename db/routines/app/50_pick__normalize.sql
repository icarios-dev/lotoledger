begin;
set role app_loto_owner;

create or replace function app.normalize_pick(p_pick app.main_num[])
returns app.main_num[]
language sql
immutable
as $$
	select coalesce(array_agg(distinct x order by x), '{}'::app.main_num[])
	from unnest(p_pick) as x;
$$;

reset role;
commit;

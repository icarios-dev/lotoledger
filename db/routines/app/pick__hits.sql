begin;
set role app_loto_owner;

create or replace function app.pick_hits(p_pick app.main_num[])
returns table (
	draw_date date,
	main_sorted app.main_num[],
	bonus_value int
)
language sql
stable
as $$
	select d.draw_date, d.main_sorted, d.bonus_value
	from app.draws d
	where d.main_sorted @> p_pick
	order by d.draw_date;
$$;

reset role;
commit;

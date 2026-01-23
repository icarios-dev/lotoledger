begin;
set role app_loto_owner;

create or replace function work.ingest_raw5()
returns bigint
language sql
as $$
with ins as (
	insert into app.draws(
		rule_set,
		draw_sub,
		draw_date,
		order_nums,
		bonus_type,
		bonus_value)
	select
		'modern_5p_chance'::app.rule_set,
		1::app.draw_sub,
		to_date(btrim(r.date_de_tirage), 'dd/mm/yyyy'),
		array[
			work.to_main_num(r.boule_1),
			work.to_main_num(r.boule_2),
			work.to_main_num(r.boule_3),
			work.to_main_num(r.boule_4),
			work.to_main_num(r.boule_5)
			],
		'chance'::app.bonus_type,
		nullif(btrim(r.numero_chance), '')::int
	from work.raw5 r
	where
		work.present(r.date_de_tirage)
		and work.present(r.boule_1)
		and work.present(r.boule_2)
		and work.present(r.boule_3)
		and work.present(r.boule_4)
		and work.present(r.boule_5)
		and work.present(r.numero_chance)
	on conflict (rule_set, draw_date, draw_sub) do nothing
	returning 1
)
select count(*) from ins;
$$;

create or replace function work.ingest_raw5second()
returns bigint
language sql
as $$
with ins as (
	insert into app.draws(
		rule_set,
		draw_sub,
		draw_date,
		order_nums,
		bonus_type,
		bonus_value)
	select
		'modern_5p'::app.rule_set,
		2::app.draw_sub,
		to_date(btrim(r.date_de_tirage), 'dd/mm/yyyy'),
		array[
			work.to_main_num(r.boule_1_second_tirage),
			work.to_main_num(r.boule_2_second_tirage),
			work.to_main_num(r.boule_3_second_tirage),
			work.to_main_num(r.boule_4_second_tirage),
			work.to_main_num(r.boule_5_second_tirage)
			],
		null,
		null
	from work.raw5 r
	where
		work.present(r.date_de_tirage)
		and work.present(r.boule_1)
		and work.present(r.boule_2)
		and work.present(r.boule_3)
		and work.present(r.boule_4)
		and work.present(r.boule_5)
	on conflict (rule_set, draw_date, draw_sub) do nothing
	returning 1
)
select count(*) from ins;
$$;

reset role;
commit;

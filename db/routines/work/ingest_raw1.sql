begin;
set role app_loto_owner;

create or replace function work.ingest_raw1()
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
		'legacy_6p_comp'::app.rule_set,
		btrim(r."1er_ou_2eme_tirage")::app.draw_sub,
		to_date(btrim(r.date_de_tirage), 'yyyymmdd'),
		array[
			work.to_main_num(r.boule_1),
			work.to_main_num(r.boule_2),
			work.to_main_num(r.boule_3),
			work.to_main_num(r.boule_4),
			work.to_main_num(r.boule_5),
			work.to_main_num(r.boule_6)
			],
		'complementaire'::app.bonus_type,
		nullif(btrim(r.boule_complementaire), '')::int
	from work.raw1 r
	where
		work.present(r.date_de_tirage)
		and work.present(r.boule_1)
		and work.present(r.boule_2)
		and work.present(r.boule_3)
		and work.present(r.boule_4)
		and work.present(r.boule_5)
		and work.present(r.boule_6)
		and work.present(r.boule_complementaire)
	on conflict(rule_set, draw_date, draw_sub) do nothing
	returning 1
)
select count(*) from ins;
$$;

reset role;
commit;

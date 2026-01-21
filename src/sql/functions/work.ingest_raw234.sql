begin;
set role app_loto_owner;

create or replace function work.ingest_raw234(r anyelement)
returns boolean
language sql
as $$
	insert into app.draws(
		rule_set,
		draw_sub,
		draw_date,
		order_nums,
		bonus_type,
		bonus_value)
	select
		'modern_5p_chance'::app.rule_set,
		null,
		-- pgls-ignore-start typecheck
		to_date(btrim((r).date_de_tirage), 'dd/mm/yyyy'),
		-- pgls-ignore-end typecheck
		array[
			work.to_main_num((r).boule_1),
			work.to_main_num((r).boule_2),
			work.to_main_num((r).boule_3),
			work.to_main_num((r).boule_4),
			work.to_main_num((r).boule_5)
			],
		'chance'::app.bonus_type,
		nullif(btrim((r).numero_chance), '')::int
	where
		work.present(r.date_de_tirage)
		and work.present(r.boule_1)
		and work.present(r.boule_2)
		and work.present(r.boule_3)
		and work.present(r.boule_4)
		and work.present(r.boule_5)
		and work.present(r.numero_chance)
	on conflict (rule_set, draw_date, draw_sub) do nothing
	returning true
$$;

create or replace function work.ingest_raw2()
returns bigint
language sql
as $$
	select count(*)
	from work.raw2 r
	where work.ingest_raw234(r);
$$;

create or replace function work.ingest_raw34()
returns bigint
language sql
as $$
	select count(*)
	from work.raw34 r
	where work.ingest_raw234(r);
$$;

reset role;
commit;

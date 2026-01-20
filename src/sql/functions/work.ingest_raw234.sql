begin;
set role app_loto_owner;

create or replace function work.ingest_raw234(r anyelement)
returns boolean
language sql
as $$
	insert into app.draws(
		rule_set,
		draw_ref,
		draw_sub,
		draw_date,
		order_nums,
		main_sorted,
		bonus_type,
		bonus_value)
	select
		'modern_5p_chance',
		-- pgls-ignore-start typecheck
		(r).annee_numero_de_tirage::int,
		-- pgls-ignore-end typecheck
		null,
		to_date(btrim((r).date_de_tirage), 'dd/mm/yyyy'),
		array[
			nullif(btrim((r).boule_1), '')::int,
			nullif(btrim((r).boule_2), '')::int,
			nullif(btrim((r).boule_3), '')::int,
			nullif(btrim((r).boule_4), '')::int,
			nullif(btrim((r).boule_5), '')::int
			],
		string_to_array(split_part(btrim((r).combinaison_gagnante_en_ordre_croissant), '+', 1), '-')::int[],
		'chance',
		nullif(btrim((r).numero_chance), '')::int
	where
		nullif(btrim((r).combinaison_gagnante_en_ordre_croissant), '') is not null
	on conflict (rule_set, draw_ref, draw_sub) do nothing
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

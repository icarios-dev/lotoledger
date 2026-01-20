begin;
set role app_loto_owner;

create or replace function work.ingest_raw5()
returns bigint
language sql
as $$
with ins as (
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
		r.annee_numero_de_tirage::int,
		1,
		to_date(btrim(r.date_de_tirage), 'dd/mm/yyyy'),
		array[
			nullif(btrim(r.boule_1), '')::int,
			nullif(btrim(r.boule_2), '')::int,
			nullif(btrim(r.boule_3), '')::int,
			nullif(btrim(r.boule_4), '')::int,
			nullif(btrim(r.boule_5), '')::int
			],
		string_to_array(split_part(btrim(r.combinaison_gagnante_en_ordre_croissant), '+', 1), '-')::int[],
		'chance',
		nullif(btrim(r.numero_chance), '')::int
	from work.raw5 r
	where
		nullif(btrim(r.combinaison_gagnante_en_ordre_croissant), '') is not null
	on conflict (rule_set, draw_ref, draw_sub) do nothing
	returning 1
)
select count(*) from ins;
$$;

reset role;
commit;

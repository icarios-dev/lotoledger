begin;
set role app_loto_owner;

create or replace function work.ingest_raw1()
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
		'legacy_6p_comp',
		r.annee_numero_de_tirage::int,
		btrim(r."1er_ou_2eme_tirage")::app.sub,
		to_date(btrim(r.date_de_tirage), 'yyyymmdd'),
		array[
			nullif(btrim(r.boule_1), '')::int,
			nullif(btrim(r.boule_2), '')::int,
			nullif(btrim(r.boule_3), '')::int,
			nullif(btrim(r.boule_4), '')::int,
			nullif(btrim(r.boule_5), '')::int,
			nullif(btrim(r.boule_6), '')::int
			],
		string_to_array(btrim(r.combinaison_gagnante_en_ordre_croissant), '-')::int[],
		'complementaire',
		nullif(btrim(r.boule_complementaire), '')::int
	from work.raw1 r
	where
		nullif(btrim(r.combinaison_gagnante_en_ordre_croissant), '') is not null
	on conflict(rule_set, draw_ref, draw_sub) do nothing
	returning 1
)
select count(*) from ins;
$$;

reset role;
commit;

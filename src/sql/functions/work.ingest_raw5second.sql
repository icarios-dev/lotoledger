begin;
set role app_loto_owner;

create or replace function work.ingest_raw5second()
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
		'second_5p',
		r.annee_numero_de_tirage,
		'second_tirage',
		d.draw_date,
		array[
			nullif(btrim(r.boule_1), '')::int,
			nullif(btrim(r.boule_2), '')::int,
			nullif(btrim(r.boule_3), '')::int,
			nullif(btrim(r.boule_4), '')::int,
			nullif(btrim(r.boule_5), '')::int
			],
		ms.main_sorted,
		null,
		null
	from work.raw5 r
	cross join lateral
		(
			select to_date(btrim(r.date_de_tirage), 'dd/mm/yyyy') as draw_date
		) d
	cross join lateral
		(
			select
				string_to_array(btrim(r.combinaison_gagnant_second_tirage_en_ordre_croissant), '-')::int[]
				as main_sorted
		) ms
	where
		nullif(btrim(r.combinaison_gagnant_second_tirage_en_ordre_croissant), '') is not null
	on conflict (rule_set, draw_ref, draw_sub) do nothing
	returning 1
)
select count(*) from ins;
$$;

reset role;
commit;

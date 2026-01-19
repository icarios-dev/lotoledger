-- populate.pgsq
-- à exécuter avec un user membre de etl_write
--
-- psql -d app_loto \
--   -v f1976_2008=/abs/path/loto-1976-2008.csv -v s1976_2008=loto-1976-2008.csv \
--   -v f2008_2017=/abs/path/loto-2008-2017.csv -v s2008_2017=loto-2008-2017.csv \
--   -v f2017_2019=/abs/path/loto-2017-2019.csv -v s2017_2019=loto-2017-2019.csv \
--   -v f2019_2019=/abs/path/loto-2019-2019.csv -v s2019_2019=loto-2019-2019.csv \
--   -v f2019_2025=/abs/path/loto-2019-2025.csv -v s2019_2025=loto-2019-2025.csv \
--   -f populate.pgsql
-- noqa: disable=AL03
begin;
set role app_loto_admin;
set search_path = work, app;
truncate table app.draws;
truncate table work.raw1;
truncate table work.raw234;
truncate table work.raw5;
-- -----------------------------------------------------------------------------
-- legacy: 1976-2008 (6 + complementaire, date yyyymmdd)
-- -----------------------------------------------------------------------------
\copy work.raw1 from '/home/bildoon/dev/loto/assets/loto-1976-2008.csv' with (format csv, delimiter ';', header true)
insert into app.draws(rule_set, source_file, draw_ref, draw_sub, draw_date, draw_dow, draw_day, order_nums,
    main_sorted, bonus_type, bonus_value, draw_key)
select
    'legacy_6p_comp',
    : 's1976_2008',
    r.annee_numero_de_tirage,
    btrim(r."1er_ou_2eme_tirage"),
    d.draw_date,
    extract(isodow from d.draw_date)::smallint,
    coalesce(work.normalize_draw_day(r.jour_de_tirage), case extract(isodow from d.draw_date)::int
        when 1 then
            'lundi'
        when 2 then
            'mardi'
        when 3 then
            'mercredi'
        when 4 then
            'jeudi'
        when 5 then
            'vendredi'
        when 6 then
            'samedi'
        when 7 then
            'dimanche'
        end),
    array[nullif(btrim(r.boule_1), '')::int, nullif(btrim(r.boule_2), '')::int, nullif(btrim(r.boule_3),
	'')::int, nullif(btrim(r.boule_4), '')::int, nullif(btrim(r.boule_5), '')::int,
	nullif(btrim(r.boule_6), '')::int],
    string_to_array(btrim(r.combinaison_gagnante_en_ordre_croissant), '-')::int[],
    'complementaire',
    nullif(btrim(r.boule_complementaire), '')::int,
    'm:' || btrim(r.combinaison_gagnante_en_ordre_croissant) || '|complementaire:' || btrim(r.boule_complementaire)
from
    work.raw1 r
    cross join lateral (
        select
            to_date(btrim(r.date_de_tirage), 'yyyymmdd') as draw_date) d
where
    nullif(btrim(r.combinaison_gagnante_en_ordre_croissant), '') is not null
on conflict (rule_set,
    draw_ref,
    draw_sub)
    do nothing;
truncate table work.raw1;
-- -----------------------------------------------------------------------------
-- modern: 2008-2017 (5 + chance, date dd/mm/yyyy)
-- -----------------------------------------------------------------------------
\copy work.raw234(annee_numero_de_tirage, jour_de_tirage, date_de_tirage, date_de_forclusion, boule_1, boule_2,
    boule_3, boule_4, boule_5, numero_chance, combinaison_gagnante_en_ordre_croissant, nombre_de_gagnant_au_rang1,
    rapport_du_rang1, nombre_de_gagnant_au_rang2, rapport_du_rang2, nombre_de_gagnant_au_rang3, rapport_du_rang3,
    nombre_de_gagnant_au_rang4, rapport_du_rang4, nombre_de_gagnant_au_rang5, rapport_du_rang5,
    nombre_de_gagnant_au_rang6, rapport_du_rang6, numero_jokerplus, devise, trailing_empty) from '/home/bildoon/dev/loto/assets/loto-2008-2017.csv' with
    (format csv, delimiter ';', header true) -- noqa : LT05
insert into app.draws(rule_set, source_file, draw_ref, draw_sub, draw_date, draw_dow, draw_day, order_nums,
    main_sorted, bonus_type, bonus_value, draw_key)
select
    'modern_5p_chance',
    : 's2008_2017',
    r.annee_numero_de_tirage,
    null,
    d.draw_date,
    extract(isodow from d.draw_date)::smallint,
    coalesce(work.normalize_draw_day(r.jour_de_tirage), case extract(isodow from d.draw_date)::int
        when 1 then
            'lundi'
        when 2 then
            'mardi'
        when 3 then
            'mercredi'
        when 4 then
            'jeudi'
        when 5 then
            'vendredi'
        when 6 then
            'samedi'
        when 7 then
            'dimanche'
        end),
    array[nullif(btrim(r.boule_1), '')::int, nullif(btrim(r.boule_2), '')::int, nullif(btrim(r.boule_3),
	'')::int, nullif(btrim(r.boule_4), '')::int, nullif(btrim(r.boule_5), '')::int],
    string_to_array(split_part(btrim(r.combinaison_gagnante_en_ordre_croissant), '+', 1), '-')::int[],
    'chance',
    nullif(btrim(r.numero_chance), '')::int,
    'm:' || split_part(btrim(r.combinaison_gagnante_en_ordre_croissant), '+', 1) ||
	'|chance:' || btrim(r.numero_chance)
from
    work.raw234 r
    cross join lateral (
        select
            to_date(btrim(r.date_de_tirage), 'dd/mm/yyyy') as draw_date) d
where
    nullif(btrim(r.combinaison_gagnante_en_ordre_croissant), '') is not null
on conflict (rule_set,
    draw_ref,
    draw_sub)
    do nothing;
truncate table work.raw234;
-- -----------------------------------------------------------------------------
-- modern: 2017-2019
-- -----------------------------------------------------------------------------
\copy work.raw234 from '/home/bildoon/dev/loto/assets/loto-2017-2019.csv' with (format csv, delimiter ';', header true)
insert into app.draws(rule_set, source_file, draw_ref, draw_sub, draw_date, draw_dow, draw_day, order_nums,
    main_sorted, bonus_type, bonus_value, draw_key)
select
    'modern_5p_chance',
    : 's2017_2019',
    r.annee_numero_de_tirage,
    null,
    d.draw_date,
    extract(isodow from d.draw_date)::smallint,
    coalesce(work.normalize_draw_day(r.jour_de_tirage), case extract(isodow from d.draw_date)::int
        when 1 then
            'lundi'
        when 2 then
            'mardi'
        when 3 then
            'mercredi'
        when 4 then
            'jeudi'
        when 5 then
            'vendredi'
        when 6 then
            'samedi'
        when 7 then
            'dimanche'
        end),
    array[nullif(btrim(r.boule_1), '')::int, nullif(btrim(r.boule_2), '')::int, nullif(btrim(r.boule_3),
	'')::int, nullif(btrim(r.boule_4), '')::int, nullif(btrim(r.boule_5), '')::int],
    string_to_array(split_part(btrim(r.combinaison_gagnante_en_ordre_croissant), '+', 1), '-')::int[],
    'chance',
    nullif(btrim(r.numero_chance), '')::int,
    'm:' || split_part(btrim(r.combinaison_gagnante_en_ordre_croissant), '+', 1) ||
	'|chance:' || btrim(r.numero_chance)
from
    work.raw234 r
    cross join lateral (
        select
            to_date(btrim(r.date_de_tirage), 'dd/mm/yyyy') as draw_date) d
where
    nullif(btrim(r.combinaison_gagnante_en_ordre_croissant), '') is not null
on conflict (rule_set,
    draw_ref,
    draw_sub)
    do nothing;
truncate table work.raw234;
-- -----------------------------------------------------------------------------
-- modern: 2019-2019
-- -----------------------------------------------------------------------------
\copy work.raw234 from '/home/bildoon/dev/loto/assets/loto-2019-2019.csv' with (format csv, delimiter ';', header true)
insert into app.draws(rule_set, source_file, draw_ref, draw_sub, draw_date, draw_dow, draw_day, order_nums,
    main_sorted, bonus_type, bonus_value, draw_key)
select
    'modern_5p_chance',
    : 's2019_2019',
    r.annee_numero_de_tirage,
    null,
    d.draw_date,
    extract(isodow from d.draw_date)::smallint,
    coalesce(work.normalize_draw_day(r.jour_de_tirage), case extract(isodow from d.draw_date)::int
        when 1 then
            'lundi'
        when 2 then
            'mardi'
        when 3 then
            'mercredi'
        when 4 then
            'jeudi'
        when 5 then
            'vendredi'
        when 6 then
            'samedi'
        when 7 then
            'dimanche'
        end),
    array[nullif(btrim(r.boule_1), '')::int, nullif(btrim(r.boule_2), '')::int, nullif(btrim(r.boule_3),
	'')::int, nullif(btrim(r.boule_4), '')::int, nullif(btrim(r.boule_5), '')::int],
    string_to_array(split_part(btrim(r.combinaison_gagnante_en_ordre_croissant), '+', 1), '-')::int[],
    'chance',
    nullif(btrim(r.numero_chance), '')::int,
    'm:' || split_part(btrim(r.combinaison_gagnante_en_ordre_croissant), '+', 1) ||
	'|chance:' || btrim(r.numero_chance)
from
    work.raw234 r
    cross join lateral (
        select
            to_date(btrim(r.date_de_tirage), 'dd/mm/yyyy') as draw_date) d
where
    nullif(btrim(r.combinaison_gagnante_en_ordre_croissant), '') is not null
on conflict (rule_set,
    draw_ref,
    draw_sub)
    do nothing;
truncate table work.raw234;
-- -----------------------------------------------------------------------------
-- modern + second: 2019-2025 (raw5)
-- -----------------------------------------------------------------------------
\copy work.raw5 from '/home/bildoon/dev/loto/assets/loto-2019-2025.csv' with (format csv, delimiter ';', header true)
-- principal: 5 + chance
insert into app.draws(rule_set, source_file, draw_ref, draw_sub, draw_date, draw_dow, draw_day, order_nums,
    main_sorted, bonus_type, bonus_value, draw_key)
select
    'modern_5p_chance',
    : 's2019_2025',
    r.annee_numero_de_tirage,
    'principal',
    d.draw_date,
    extract(isodow from d.draw_date)::smallint,
    coalesce(work.normalize_draw_day(r.jour_de_tirage), case extract(isodow from d.draw_date)::int
        when 1 then
            'lundi'
        when 2 then
            'mardi'
        when 3 then
            'mercredi'
        when 4 then
            'jeudi'
        when 5 then
            'vendredi'
        when 6 then
            'samedi'
        when 7 then
            'dimanche'
        end),
    array[nullif(btrim(r.boule_1), '')::int, nullif(btrim(r.boule_2), '')::int, nullif(btrim(r.boule_3),
	'')::int, nullif(btrim(r.boule_4), '')::int, nullif(btrim(r.boule_5), '')::int],
    string_to_array(split_part(btrim(r.combinaison_gagnante_en_ordre_croissant), '+', 1), '-')::int[],
    'chance',
    nullif(btrim(r.numero_chance), '')::int,
    'm:' || split_part(btrim(r.combinaison_gagnante_en_ordre_croissant), '+', 1) ||
	'|chance:' || btrim(r.numero_chance)
from
    work.raw5 r
    cross join lateral (
        select
            to_date(btrim(r.date_de_tirage), 'dd/mm/yyyy') as draw_date) d
where
    nullif(btrim(r.combinaison_gagnante_en_ordre_croissant), '') is not null
on conflict (rule_set,
    draw_ref,
    draw_sub)
    do nothing;
-- second tirage: 5, no chance
insert into app.draws(rule_set, source_file, draw_ref, draw_sub, draw_date, draw_dow, draw_day, order_nums,
    main_sorted, bonus_type, bonus_value, draw_key)
select
    'second_5p',
    : 's2019_2025',
    r.annee_numero_de_tirage,
    'second_tirage',
    d.draw_date,
    extract(isodow from d.draw_date)::smallint,
    coalesce(work.normalize_draw_day(r.jour_de_tirage), case extract(isodow from d.draw_date)::int
        when 1 then
            'lundi'
        when 2 then
            'mardi'
        when 3 then
            'mercredi'
        when 4 then
            'jeudi'
        when 5 then
            'vendredi'
        when 6 then
            'samedi'
        when 7 then
            'dimanche'
        end),
    array[nullif(btrim(r.boule_1_second_tirage), '')::int, nullif(btrim(r.boule_2_second_tirage), '')::int,
	nullif(btrim(r.boule_3_second_tirage), '')::int, nullif(btrim(r.boule_4_second_tirage), '')::int,
	nullif(btrim(r.boule_5_second_tirage), '')::int],
    string_to_array(btrim(r.combinaison_gagnant_second_tirage_en_ordre_croissant), '-')::int[],
    null,
    null,
    'm:' || btrim(r.combinaison_gagnant_second_tirage_en_ordre_croissant)
from
    work.raw5 r
    cross join lateral (
        select
            to_date(btrim(r.date_de_tirage), 'dd/mm/yyyy') as draw_date) d
where
    nullif(btrim(r.combinaison_gagnant_second_tirage_en_ordre_croissant), '') is not null
on conflict (rule_set,
    draw_ref,
    draw_sub)
    do nothing;
truncate table work.raw5;
reset role;
commit;

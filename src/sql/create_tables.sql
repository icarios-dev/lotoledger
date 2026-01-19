begin;
--
set role app_loto_owner;
--
-- place nette
--
-- pgls-ignore-start lint/safety/banDropTable
drop table if exists app.draws, work.raw1, work.raw234, work.raw5;
-- pgls-ignore-end lint/safety/banDropTable
drop type if exists app.rule_set, app.bonus_type, app.day;
drop domain if exists app.main_num, app.sub;
--
-- contraintes / types custom
--
create type app.rule_set as enum(
    'legacy_6p_comp',
    'modern_5p_chance',
    'second_5p'
);
create type app.bonus_type as enum(
    'chance',
    'complementaire'
);
create type app.day as enum(
    'lundi',
    'mardi',
    'mercredi',
    'jeudi',
    'vendredi',
    'samedi',
    'dimanche'
);
create domain app.main_num as int check (value between 1 and 49);
create domain app.sub as int check (value between 1 and 2);
--
-- canonical table in app
--
-- pgls-ignore-start typecheck
create or replace function app.expected_main_count(rs app.rule_set)
    returns int
    language sql
    immutable
    as $$
    select
        case rs
        when 'legacy_6p_comp' then
            6
        when 'modern_5p_chance' then
            5
        when 'second_5p' then
            5
        end
$$;
-- pgls-ignore-end typecheck
--
-- pgls-ignore-start typecheck
create or replace function app.array_no_dupes(a int[])
    returns boolean
    language sql
    immutable
    as $$
    select
        cardinality(a) = cardinality(array( select distinct unnest(a)))
$$;
-- pgls-ignore-end typecheck
--
-- pgls-ignore-start typecheck
create or replace function app.valid_bonus(bt app.bonus_type, bv int)
    returns boolean
    language sql
    immutable
    as $$
    select
      (bt is null and bv is null)
      or (bt = 'chance' and bv between 1 and 10)
      or (bt = 'complementaire' and bv between 1 and 49)
$$;
-- pgls-ignore-end typecheck
--
-- pgls-ignore-start typecheck
create or replace function app.bonus_expected(rs app.rule_set, bt app.bonus_type)
    returns boolean
    language sql
    immutable
    as $$
    select
      (rs = 'legacy_6p_comp' and bt = 'complementaire')
      or (rs = 'modern_5p_chance' and bt = 'chance')
      or (rs = 'second_5p' and bt is null)
$$;
-- pgls-ignore-end typecheck
--
create table app.draws(
    id bigserial primary key,
    rule_set app.rule_set not null,
    draw_ref int not null,
    draw_sub app.sub,
    draw_date date not null,
    order_nums app.main_num[] not null,
    main_sorted app.main_num[] not null,
    bonus_type app.bonus_type,
    bonus_value int, -- plage vérifiée par contrainte
    draw_key text generated always as (
		app.make_draw_key(main_sorted, bonus_type, bonus_value)
	) stored,
    unique (rule_set, draw_ref, draw_sub),
    constraint order_nums_len check (array_length(order_nums, 1) = app.expected_main_count(rule_set)),
    constraint array_same_len check (array_length(main_sorted, 1) = array_length(order_nums, 1)),
    constraint no_dupes check (app.array_no_dupes(main_sorted)),
    constraint expected_bonus check (app.bonus_expected(rule_set, bonus_type)),
    constraint bonus_valid check (app.valid_bonus(bonus_type, bonus_value))
);
create index if not exists draws_date_idx on app.draws(draw_date);
create index if not exists draws_main_sorted_gin on app.draws using gin(main_sorted);
create index if not exists draws_order_nums_gin on app.draws using gin(order_nums);
create index if not exists draws_draw_key_idx on app.draws(rule_set, draw_key);
--
-- staging tables in work
--
create table work.raw1(
    annee_numero_de_tirage text,
    "1er_ou_2eme_tirage" text,
    jour_de_tirage text,
    date_de_tirage text,
    date_de_forclusion text,
    boule_1 text,
    boule_2 text,
    boule_3 text,
    boule_4 text,
    boule_5 text,
    boule_6 text,
    boule_complementaire text,
    combinaison_gagnante_en_ordre_croissant text,
    numero_joker text,
    nombre_de_gagnant_au_rang1 text,
    rapport_du_rang1 text,
    nombre_de_gagnant_au_rang2 text,
    rapport_du_rang2 text,
    nombre_de_gagnant_au_rang3 text,
    rapport_du_rang3 text,
    nombre_de_gagnant_au_rang4 text,
    rapport_du_rang4 text,
    nombre_de_gagnant_au_rang5 text,
    rapport_du_rang5 text,
    nombre_de_gagnant_au_rang6 text,
    rapport_du_rang6 text,
    nombre_de_gagnant_au_rang7 text,
    rapport_du_rang7 text,
    numero_jokerplus text,
    devise text,
    trailing_empty text
);
create table work.raw2(
    annee_numero_de_tirage text,
    jour_de_tirage text,
    date_de_tirage text,
    date_de_forclusion text,
    boule_1 text,
    boule_2 text,
    boule_3 text,
    boule_4 text,
    boule_5 text,
    numero_chance text,
    combinaison_gagnante_en_ordre_croissant text,
    nombre_de_gagnant_au_rang1 text,
    rapport_du_rang1 text,
    nombre_de_gagnant_au_rang2 text,
    rapport_du_rang2 text,
    nombre_de_gagnant_au_rang3 text,
    rapport_du_rang3 text,
    nombre_de_gagnant_au_rang4 text,
    rapport_du_rang4 text,
    nombre_de_gagnant_au_rang5 text,
    rapport_du_rang5 text,
    nombre_de_gagnant_au_rang6 text,
    rapport_du_rang6 text,
    numero_jokerplus text,
    devise text,
    -- les lignes finissent par un ';' (champ vide terminal)
    trailing_empty text
);
create table work.raw34(
    annee_numero_de_tirage text,
    jour_de_tirage text,
    date_de_tirage text,
    date_de_forclusion text,
    boule_1 text,
    boule_2 text,
    boule_3 text,
    boule_4 text,
    boule_5 text,
    numero_chance text,
    combinaison_gagnante_en_ordre_croissant text,
    nombre_de_gagnant_au_rang1 text,
    rapport_du_rang1 text,
    nombre_de_gagnant_au_rang2 text,
    rapport_du_rang2 text,
    nombre_de_gagnant_au_rang3 text,
    rapport_du_rang3 text,
    nombre_de_gagnant_au_rang4 text,
    rapport_du_rang4 text,
    nombre_de_gagnant_au_rang5 text,
    rapport_du_rang5 text,
    nombre_de_gagnant_au_rang6 text,
    rapport_du_rang6 text,
    nombre_de_gagnant_au_rang7 text,
    rapport_du_rang7 text,
    nombre_de_gagnant_au_rang8 text,
    rapport_du_rang8 text,
    nombre_de_gagnant_au_rang9 text,
    rapport_du_rang9 text,
    nombre_de_codes_gagnants text,
    rapport_codes_gagnants text,
    codes_gagnants text,
    numero_jokerplus text,
    devise text,
    -- les lignes finissent par un ';' (champ vide terminal)
    trailing_empty text
);
create table work.raw5(
    annee_numero_de_tirage text,
    jour_de_tirage text,
    date_de_tirage text,
    date_de_forclusion text,
    boule_1 text,
    boule_2 text,
    boule_3 text,
    boule_4 text,
    boule_5 text,
    numero_chance text,
    combinaison_gagnante_en_ordre_croissant text,
    nombre_de_gagnant_au_rang1 text,
    rapport_du_rang1 text,
    nombre_de_gagnant_au_rang2 text,
    rapport_du_rang2 text,
    nombre_de_gagnant_au_rang3 text,
    rapport_du_rang3 text,
    nombre_de_gagnant_au_rang4 text,
    rapport_du_rang4 text,
    nombre_de_gagnant_au_rang5 text,
    rapport_du_rang5 text,
    nombre_de_gagnant_au_rang6 text,
    rapport_du_rang6 text,
    nombre_de_gagnant_au_rang7 text,
    rapport_du_rang7 text,
    nombre_de_gagnant_au_rang8 text,
    rapport_du_rang8 text,
    nombre_de_gagnant_au_rang9 text,
    rapport_du_rang9 text,
    nombre_de_codes_gagnants text,
    rapport_codes_gagnants text,
    codes_gagnants text,
    boule_1_second_tirage text,
    boule_2_second_tirage text,
    boule_3_second_tirage text,
    boule_4_second_tirage text,
    boule_5_second_tirage text,
    promotion_second_tirage text,
    combinaison_gagnant_second_tirage_en_ordre_croissant text,
    nombre_de_gagnant_au_rang_1_second_tirage text,
    rapport_du_rang1_second_tirage text,
    nombre_de_gagnant_au_rang_2_second_tirage text,
    rapport_du_rang2_second_tirage text,
    nombre_de_gagnant_au_rang_3_second_tirage text,
    rapport_du_rang3_second_tirage text,
    nombre_de_gagnant_au_rang_4_second_tirage text,
    rapport_du_rang4_second_tirage text,
    numero_jokerplus text,
    devise text,
    trailing_empty text
);
--
reset role;
--
commit;

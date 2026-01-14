-- build.sql
-- à exécuter en tant que superuser (une fois) dans la base app_loto
-- prépare: rôles + schémas + privilèges par défaut

begin;

  -- --------------------
  -- roles
  -- --------------------
  create role app_loto_owner nologin;
  create role app_loto_user nologin;
  create role app_loto_admin nologin;

  -- users login (à adapter)
  -- create role app_loto_owner_user login password '...';
  -- create role app_user login password '...';
  -- create role etl_user login password '...';
  -- grant app_loto_owner to app_loto_owner_user;
  -- grant app_loto_user to app_user;
  -- grant app_loto_admin to etl_user;

  -- --------------------------
  -- schémas
  -- --------------------------
  create schema if not exists app authorization app_loto_owner;
  create schema if not exists work authorization app_loto_owner;

  revoke all on schema public from public;
  revoke create on schema public from public;

  alter role app_loto_user set search_path = app;
  alter role app_loto_admin set search_path = work, app;

  -- -------------------------------
  -- tables & functions
  -- ---------------------------------
  set role app_loto_owner;

  -- function in work (import helpers)
  create or replace function work.normalize_draw_day(input text)
  returns text
  language sql
  immutable
  as $$
    select case upper(btrim(coalesce(input, '')))
      when 'lundi' then 'lundi'
      when 'mardi' then 'mardi'
      when 'mercredi' then 'mercredi'
      when 'jeudi' then 'jeudi'
      when 'vendredi' then 'vendredi'
      when 'samedi' then 'samedi'
      when 'dimanche' then 'dimanche'
      when 'lu' then 'lundi'
      when 'ma' then 'mardi'
      when 'me' then 'mercredi'
      when 'mer' then 'mercredi'
      when 'je' then 'jeudi'
      when 've' then 'vendredi'
      when 'sa' then 'samedi'
      when 'sam' then 'samedi'
      when 'di' then 'dimanche'
      when 'dim' then 'dimanche'
      else null
    end;
  $$;

  -- canonical table in app
  create table if not exists app.draws (
    id          bigserial primary key,

    rule_set    text not null,      -- 'legacy_6p_comp' | 'modern_5p_chance' | 'second_5p'
    source_file text not null,      -- basename ex: 'loto-2019-2025.csv'
    draw_ref    text,
    draw_sub    text,

    draw_date   date not null,
    draw_dow    smallint,
    draw_day    text,

    order_nums  int[] not null,
    main_sorted int[] not null,
    bonus_type  text,               -- 'chance' | 'complementaire' | null
    bonus_value int,

    draw_key    text not null
  );

  create index if not exists draws_date_idx on app.draws(draw_date);
  create index if not exists draws_main_sorted_gin on app.draws using gin (main_sorted);
  create index if not exists draws_order_nums_gin on app.draws using gin (order_nums);
  create index if not exists draws_draw_key_idx on app.draws(draw_key);

  alter table app.draws add constraint draws_event_uniq unique (rule_set, draw_ref, draw_sub);

  -- staging tables in work

  drop table if exists work.raw1;
  create table work.raw1 (
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

  drop table if exists work.raw234;
  create table if not exists work.raw234 (
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

  drop table if exists work.raw5;
  create table if not exists work.raw5 (
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

  ------------------------------
  -- privilèges
  -- -----------------------------
  -- schema visibility
  grant usage on schema app to app_loto_user;
  grant usage on schema app to app_loto_admin;
  grant usage on schema work to app_loto_admin;

  -- app objects
  grant select on app.draws to app_loto_user;

  -- etl can load data (rebuild: needs truncate too)
  grant select, insert on app.draws to app_loto_admin;
  grant truncate on app.draws to app_loto_admin;
  grant usage, select on sequence app.draws_id_seq to app_loto_admin;

  -- work objects (etl full control on staging)
  grant select, insert, update, delete, truncate on work.raw1 to app_loto_admin;
  grant select, insert, update, delete, truncate on work.raw234 to app_loto_admin;
  grant select, insert, update, delete, truncate on work.raw5 to app_loto_admin;
  grant execute on function work.normalize_draw_day(text) to app_loto_admin;

  -- default privileges for future objects created by app_loto_owner
  alter default privileges for role app_loto_owner in schema app
    grant select on tables to app_loto_user;

  alter default privileges for role app_loto_owner in schema app
    grant select, insert on tables to app_loto_admin;

  alter default privileges for role app_loto_owner in schema app
    grant usage, select on sequences to app_loto_user;

  alter default privileges for role app_loto_owner in schema app
    grant usage, select on sequences to app_loto_admin;

  -- work: staging/etl uniquement (l'app n'y touche pas)
  alter default privileges for role app_loto_owner in schema work
    grant select, insert, update, delete on tables to app_loto_admin;

  alter default privileges for role app_loto_owner in schema work
    grant execute on functions to app_loto_admin;

  reset role;
commit;

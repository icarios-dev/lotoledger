set role app_loto_owner;

begin;
create or replace function work.ingest_raw1(source_file text)
    returns bigint
    language sql
    as $$
    with ins as(
insert into app.draws(rule_set, source_file, draw_ref, draw_sub, draw_date, draw_dow, draw_day, order_nums,
    main_sorted, bonus_type, bonus_value, draw_key)
        select
            'legacy_6p_comp',
            source_file,
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
            array[nullif(btrim(r.boule_1), '')::int,
            nullif(btrim(r.boule_2), '')::int,
            nullif(btrim(r.boule_3), '')::int,
            nullif(btrim(r.boule_4), '')::int,
            nullif(btrim(r.boule_5), '')::int,
            nullif(btrim(r.boule_6), '')::int],
            string_to_array(btrim(r.combinaison_gagnante_en_ordre_croissant), '-')::int[],
            'complementaire',
            nullif(btrim(r.boule_complementaire), '')::int,
            'm:' || btrim(r.combinaison_gagnante_en_ordre_croissant) || '|complementaire:' || btrim(r.boule_complementaire)
        from
            work.raw1 r
        cross join lateral(
            select
                to_date(btrim(r.date_de_tirage), 'yyyymmdd') as draw_date) d
        where
            nullif(btrim(r.combinaison_gagnante_en_ordre_croissant), '') is not null
        on conflict(rule_set,
            draw_ref,
            draw_sub)
            do nothing
        returning
            1
)
select
    count(*)
from
    ins;
$$;
commit;

reset role;

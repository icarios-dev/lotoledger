-- function in work (import helpers)
begin;
--
set role app_loto_owner;
--
create or replace function work.normalize_draw_day(input text)
    returns app.day
    language sql
    immutable
    as $$
    select
        case upper(btrim(coalesce(input, '')))
        when 'lundi' then
            'lundi'
        when 'mardi' then
            'mardi'
        when 'mercredi' then
            'mercredi'
        when 'jeudi' then
            'jeudi'
        when 'vendredi' then
            'vendredi'
        when 'samedi' then
            'samedi'
        when 'dimanche' then
            'dimanche'
        when 'lu' then
            'lundi'
        when 'ma' then
            'mardi'
        when 'me' then
            'mercredi'
        when 'mer' then
            'mercredi'
        when 'je' then
            'jeudi'
        when 've' then
            'vendredi'
        when 'sa' then
            'samedi'
        when 'sam' then
            'samedi'
        when 'di' then
            'dimanche'
        when 'dim' then
            'dimanche'
        else
            null
        end;
$$;
--
reset role;
--
commit;

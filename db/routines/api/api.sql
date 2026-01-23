begin;
set role app_loto_owner;

create or replace function api.draw_exists(main_sorted int[], bonus_value int)
    returns boolean
    language sql
    security definer
    set search_path = app, pg_temp
    as $$
    select
        exists(
            select
                1
            from
                app.draws d
            where
                d.main_sorted = $1
                and d.bonus_value = $2
                and d.rule_set in('modern_5p_chance', 'legacy_6p_comp') -- adapte
);
$$;

reset role;
commit;

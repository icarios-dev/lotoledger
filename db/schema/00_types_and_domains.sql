begin;
set role app_loto_owner;

drop type if exists app.rule_set, app.bonus_type cascade;
drop domain if exists app.main_num, app.draw_sub cascade;
--
--
create type app.rule_set as enum(
    'legacy_6p_comp',
    'modern_5p_chance',
    'modern_5p'
);

create type app.bonus_type as enum(
    'chance',
    'complementaire'
);

create domain app.main_num as int check (value between 1 and 49);
create domain app.draw_sub as int check (value between 1 and 2);

reset role;
commit;

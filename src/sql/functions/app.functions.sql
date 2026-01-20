begin;
set role app_loto_owner;

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
        cardinality(a) = cardinality(array( select distinct unnest(a) ))
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

-- pgls-ignore-start typecheck
create or replace function app.make_draw_key(p_main app.main_num[], p_bonus_type app.bonus_type, p_bonus_value int)
returns text
language sql
immutable
as $$
	select
	'm:' || array_to_string(p_main, '-')
	|| case
		when p_bonus_value is null then ''
		else '|' || p_bonus_type || ':' || p_bonus_value::text
		end;
$$;
-- pgls-ignore-end typecheck

reset role;
commit;

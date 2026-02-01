begin;
set role app_loto_owner;

-- pgls-ignore-start typecheck
create or replace function app.expected_main_count(rs app.rule_set)
    returns int
    language plpgsql
    immutable
    as $$
    begin
        case rs
        when 'legacy_6p_comp' then return 6;
        when 'modern_5p_chance' then return 5;
        when 'modern_5p' then return 5;
		else
			raise exception 'unsupported rule_set: %', rs;
        end case;
	end;
$$;
-- pgls-ignore-end typecheck

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

-- pgls-ignore-start typecheck
create or replace function app.expected_bonus_type(rs app.rule_set)
    returns app.bonus_type
    language plpgsql
    immutable
    as $$
    begin
		case rs
		when 'legacy_6p_comp' then return 'complementaire'::app.bonus_type;
		when 'modern_5p_chance' then return 'chance'::app.bonus_type;
		when 'modern_5p' then return null;
		else
			raise exception 'unsupported rule_set: %', rs;
        end case;
	end;
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

-- pgls-ignore-start typecheck
create or replace function app.sort_main_nums(nums app.main_num[])
returns app.main_num[]
language sql
immutable
strict
as $$
	select array_agg(n order by n)
	from unnest(nums) as n;
$$;
-- pgls-ignore-end typecheck

reset role;
commit;

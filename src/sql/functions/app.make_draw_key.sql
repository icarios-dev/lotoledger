begin;
set role app_loto_owner;

-- pgls-ignore-start typecheck
create or replace function app.make_draw_key(p_main int[], p_bonus_type text, p_bonus_value int)
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

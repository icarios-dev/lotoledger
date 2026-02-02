begin;
set role app_loto_owner;

create or replace function app.ruleset_main_max(rs app.rule_set)
    returns app.main_num
    language plpgsql
    immutable
    as $$
    begin
        case rs
        when 'legacy_6p_comp' then return 49;
        when 'modern_5p_chance' then return 49;
        when 'modern_5p' then return 49;
		else
			raise exception 'unsupported rule_set: %', rs;
        end case;
	end;
$$;

create or replace function app.ruleset_bonus_max(rs app.rule_set)
    returns int
    language plpgsql
    immutable
    as $$
    begin
        case rs
        when 'legacy_6p_comp' then return 49;
        when 'modern_5p_chance' then return 10;
        when 'modern_5p' then return null;
		else
			raise exception 'unsupported rule_set: %', rs;
        end case;
	end;
$$;

create or replace function app.ruleset_date_start(rs app.rule_set)
    returns date
    language plpgsql
    immutable
    as $$
    begin
        case rs
        when 'legacy_6p_comp' then return date '1976-05-19';
        when 'modern_5p_chance' then return date '2008-12-06';
        when 'modern_5p' then return date '2019-11-06';
		else
			raise exception 'unsupported rule_set: %', rs;
        end case;
	end;
$$;

create or replace function app.ruleset_date_end(rs app.rule_set)
    returns date
    language plpgsql
    immutable
    as $$
    begin
        case rs
        when 'legacy_6p_comp' then return date '2008-12-04';
        when 'modern_5p_chance' then return null;
        when 'modern_5p' then return null;
		else
			raise exception 'unsupported rule_set: %', rs;
        end case;
	end;
$$;

reset role;
commit;

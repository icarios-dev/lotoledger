begin;
set role app_loto_owner;

create or replace function work.to_main_num(txt text)
returns app.main_num
language sql
immutable
as $$
	select nullif(btrim(txt), '')::int::app.main_num
$$;

create or replace function work.present(txt text)
returns boolean
language sql
immutable
as $$
	select nullif(btrim(txt), '') is not null
$$;


reset role;
commit;

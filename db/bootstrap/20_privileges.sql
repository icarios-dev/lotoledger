begin;
set role app_loto_owner;

-- schema visibility
grant usage on schema app to app_loto_admin;
grant usage on schema work to app_loto_admin;
grant usage on schema api to app_loto_user;

-- etl can load data (rebuild: needs truncate too)
grant select, insert on app.draws to app_loto_admin;
grant truncate on app.draws to app_loto_admin;
grant usage, select on sequence app.draws_id_seq to app_loto_admin;

-- work objects (etl full control on staging)
grant select, insert, update, delete, truncate on work.raw1 to app_loto_admin;
grant select, insert, update, delete, truncate on work.raw2 to app_loto_admin;
grant select, insert, update, delete, truncate on work.raw34 to app_loto_admin;
grant select, insert, update, delete, truncate on work.raw5 to app_loto_admin;
grant execute on all functions in schema work to app_loto_admin;
grant execute on all functions in schema api to app_loto_user;

-- default privileges for future objects created by app_loto_owner
alter default privileges for role app_loto_owner in schema app grant
select
, insert on tables to app_loto_admin;
alter default privileges for role app_loto_owner in schema app grant usage,
select
	on sequences to app_loto_admin;

-- work: staging/etl uniquement (l'app n'y touche pas)
alter default privileges for role app_loto_owner in schema work grant
select
, insert, update, delete on tables to app_loto_admin;
alter default privileges for role app_loto_owner in schema work grant execute on functions to app_loto_admin;
alter default privileges for role app_loto_owner in schema api grant execute on functions to app_loto_user;

reset role;
commit;

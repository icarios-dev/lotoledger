-- Spécifique pour Postgres Language Server en dév
--
begin;
--
-- permet un meilleur diagnostic des fonctions PL/pgSQL
--
create extension if not exists plpgsql_check;
--
-- utilisateur dédié pour le Postgres Language Server
--
do $$
begin
  if not exists(
    select 1 from pg_roles where rolname = 'app_loto_pls'
    )
  then
    create role app_loto_pls;
  end if;
end
$$;
alter role app_loto_pls nologin;
--
set role app_loto_owner;
--
grant connect on database lotoledger to app_loto_pls;
-- visibilité schéma
grant usage on schema app to app_loto_pls;
-- droit lecture sur objets existants
grant select on all tables in schema app to app_loto_pls;
grant select on all sequences in schema app to app_loto_pls;
grant execute on all functions in schema app to app_loto_pls;
-- droits lecture sur objets futurs (créés par app_loto_owner)
alter default privileges for role app_loto_owner in schema app grant
select
    on tables to app_loto_pls;
alter default privileges for role app_loto_owner in schema app grant
select
    on sequences to app_loto_pls;
alter default privileges for role app_loto_owner in schema app grant execute on functions to app_loto_pls;
-- autocomplétion sur le schéma work
grant usage on schema work to app_loto_pls;
grant execute on all functions in schema work to app_loto_pls;
alter default privileges for role app_loto_owner in schema work grant execute on functions to app_loto_pls;
--
grant usage on schema api to app_loto_pls;
grant execute on all functions in schema api to app_loto_pls;
alter default privileges for role app_loto_owner in schema api grant execute on functions to app_loto_pls;
--
reset role;
set role postgres;
-- mon user unix/pg (login) récupère les droits via membership
grant app_loto_pls to :user_local;
--
reset role;
--
commit;

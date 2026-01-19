begin;
--
-- as app_loto_owner ----------------------
--
set role app_loto_owner;
create schema if not exists app authorization app_loto_owner;
create schema if not exists work authorization app_loto_owner;
create schema if not exists api authorization app_loto_owner;
-- aucun accès implicite
revoke all on schema public from public;
revoke all on schema api from public;
revoke all on schema app from public;
revoke all on schema work from public;
reset role;
--
-- as postgres ----------------------------
--
set role postgres;
alter role app_loto_admin set search_path = work, app;
reset role;
--
commit;

-- populate.pgsq
-- à exécuter avec un user membre de etl_write
--
-- psql -d app_loto \
--   -v f1976_2008=/abs/path/loto-1976-2008.csv -v s1976_2008=loto-1976-2008.csv \
--   -v f2008_2017=/abs/path/loto-2008-2017.csv -v s2008_2017=loto-2008-2017.csv \
--   -v f2017_2019=/abs/path/loto-2017-2019.csv -v s2017_2019=loto-2017-2019.csv \
--   -v f2019_2019=/abs/path/loto-2019-2019.csv -v s2019_2019=loto-2019-2019.csv \
--   -v f2019_2025=/abs/path/loto-2019-2025.csv -v s2019_2025=loto-2019-2025.csv \
--   -f populate.pgsql
-- noqa: disable=AL03
begin;
set role app_loto_admin;
set search_path = work, app;

truncate table app.draws;
truncate table work.raw1;
truncate table work.raw34;
truncate table work.raw5;

-- -----------------------------------------------------------------------------
-- legacy: 1976-2008 (6 + complementaire, date yyyymmdd)
-- -----------------------------------------------------------------------------
\copy work.raw1 from '/home/bildoon/dev/loto/assets/loto-1976-2008.csv' with (format csv, delimiter ';', header true)
select work.ingest_raw1();
truncate table work.raw1;
-- -----------------------------------------------------------------------------
-- modern: 2008-2017 (5 + chance, date dd/mm/yyyy)
-- -----------------------------------------------------------------------------
\copy work.raw2 from '/home/bildoon/dev/loto/assets/loto-2008-2017.csv' with (format csv, delimiter ';', header true)
select work.ingest_raw2();
truncate table work.raw2;
-- -----------------------------------------------------------------------------
-- modern: 2017-2019
-- -----------------------------------------------------------------------------
\copy work.raw34 from '/home/bildoon/dev/loto/assets/loto-2017-2019.csv' with (format csv, delimiter ';', header true)
select work.ingest_raw34();
truncate table work.raw34;
-- -----------------------------------------------------------------------------
-- modern: 2019-2019
-- -----------------------------------------------------------------------------
\copy work.raw34 from '/home/bildoon/dev/loto/assets/loto-2019-2019.csv' with (format csv, delimiter ';', header true)
select work.ingest_raw34();
truncate table work.raw34;
-- -----------------------------------------------------------------------------
-- modern + second: 2019-2025 (raw5)
-- -----------------------------------------------------------------------------
\copy work.raw5 from '/home/bildoon/dev/loto/assets/loto-2019-2025.csv' with (format csv, delimiter ';', header true)
-- principal: 5 + chance
select work.ingest_raw5();
-- second tirage: 5, no chance
select work.ingest_raw5second();
truncate table work.raw5;
reset role;
commit;

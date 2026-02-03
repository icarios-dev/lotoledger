-- populate.sql
-- à exécuter avec un user membre de etl_write
--
begin;

set search_path = work, app;

truncate table app.draws;
truncate table work.raw1;
truncate table work.raw2;
truncate table work.raw34;
truncate table work.raw5;

-- -----------------------------------------------------------------------------
-- legacy: 1976-2008 (6 + complementaire, date yyyymmdd)
-- -----------------------------------------------------------------------------
\copy work.raw1 from './tmp/data/extracted/loto/loto.csv' with (format csv, delimiter ';', NULL '', header true)
select work.ingest_raw1();
truncate table work.raw1;
-- -----------------------------------------------------------------------------
-- modern: 2008-2017 (5 + chance, date dd/mm/yyyy)
-- -----------------------------------------------------------------------------
\copy work.raw2 from './tmp/data/extracted/nouveau_loto/nouveau_loto.csv' with (format csv, delimiter ';', NULL '', header true)
select work.ingest_raw2();
truncate table work.raw2;
-- -----------------------------------------------------------------------------
-- modern: 2017-2019
-- -----------------------------------------------------------------------------
\copy work.raw34 from './tmp/data/extracted/loto2017/loto2017.csv' with (format csv, delimiter ';', NULL '', header true)
select work.ingest_raw34();
truncate table work.raw34;
-- -----------------------------------------------------------------------------
-- modern: 2019-2019
-- -----------------------------------------------------------------------------
\copy work.raw34 from './tmp/data/extracted/loto_201902/loto_201902.csv' with (format csv, delimiter ';', NULL '', header true)
select work.ingest_raw34();
truncate table work.raw34;
-- -----------------------------------------------------------------------------
-- modern + second: 2019-2025 (raw5)
-- -----------------------------------------------------------------------------
\copy work.raw5 from './tmp/data/extracted/loto_201911/loto_201911.csv' with (format csv, delimiter ';', NULL '', header true)
-- principal: 5 + chance
select work.ingest_raw5();
-- second tirage: 5, no chance
select work.ingest_raw5second();
truncate table work.raw5;

commit;

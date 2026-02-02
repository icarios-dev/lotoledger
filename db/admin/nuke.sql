-- Nettoyage par le vide
--
-- 1) couper les connexions (obligatoire si la db est utilisée)
select
    pg_terminate_backend(pid)
from
    pg_stat_activity
where
    datname = 'lotoledger'
    and pid <> pg_backend_pid();

-- 2) drop db (hors transaction, et avant les rôles)
drop database if exists lotoledger;

-- 3) retirer memberships
revoke app_loto_pls from :user_local;

-- 4) supprimer rôles (ordre: dépendants -> propriétaires)
drop role if exists app_loto_pls;
drop role if exists app_loto_user;
drop role if exists app_loto_admin;
drop role if exists app_loto_owner;

-- create_roles.sql
--
begin;
do $$
begin
    if not exists(
        select
            1
        from
            pg_roles
        where
            rolname = 'app_loto_owner') then
    create role app_loto_owner;
end if;
end
$$;
do $$
begin
    if not exists(
        select
            1
        from
            pg_roles
        where
            rolname = 'app_loto_user') then
    create role app_loto_user login;
end if;
end
$$;
do $$
begin
    if not exists(
        select
            1
        from
            pg_roles
        where
            rolname = 'app_loto_admin') then
    create role app_loto_admin login;
end if;
end
$$;
commit;

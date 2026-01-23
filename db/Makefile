DB := lotoledger
PG := /usr/bin/env psql
PROD := $(PG)
COMMAND := $(PROD)
DEBUG := # -e
PG_OPTS := -v ON_ERROR_STOP=1 $(DEBUG)
BASENAME := /usr/bin/env basename

define run_sql_as_owner
	$(COMMAND) "$(DATABASE_URL_OWNER)" $(PG_OPTS) $(addprefix -f , $^)
endef

define run_sql_as_admin
	$(COMMAND) "$(DATABASE_URL_ADMIN)" $(PG_OPTS) $(addprefix -f , $^)
endef

all:

_create_roles: bootstrap/00_roles.sql
	$(run_sql_as_owner)
	$(COMMAND) "$(DATABASE_URL_OWNER)" $(PG_OPTS) \
		-c "alter role app_loto_user with login password '$${APP_LOTO_USER_PASSWORD}' ;" \
		-c "alter role app_loto_admin with login password '$${APP_LOTO_ADMIN_PASSWORD}' ;"

_create_schemas: bootstrap/10_schemas.sql
	$(run_sql_as_owner)

_create_types_and_domains: schema/00_types_and_domains.sql
	$(run_sql_as_owner)

_create_tables: schema/10_tables.sql
	$(run_sql_as_owner)

_set_privileges: bootstrap/20_privileges.sql
	$(run_sql_as_owner)

_functions_app: routines/app/*.sql
	$(run_sql_as_owner)

_functions_work: routines/work/helpers.sql routines/work/ingest_*.sql
	$(run_sql_as_owner)

reset: _create_roles _create_schemas _create_types_and_domains

build: _functions_app _create_tables _functions_work _set_privileges

prod: reset build

populate: ingest/populate.sql
	$(run_sql_as_admin)

_role_pls: admin/pls.sql
	$(COMMAND) "$(DATABASE_URL_OWNER)" $(PG_OPTS) \
		-v user_local="$${USER}" \
		-f $<

nuke: admin/nuke.sql
	sudo -u postgres $(PG) \
		-v user_local="$${USER}" \
		-f $<

.PHONY: all _create_roles _create_schemas _role_pls _create_types_and_domains \
	_create_tables _set_privileges _functions_app _functions_work \
	reset build prod populate nuke

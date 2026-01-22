DB := lotoledger
PG := /usr/bin/env psql
PROD := $(PG)
COMMAND := $(PROD)
DEBUG := # -e
PG_OPTS := -v ON_ERROR_STOP=1 $(DEBUG)
BASENAME := /usr/bin/env basename

all:

_create_roles: create_roles.sql
	$(COMMAND) "$(DATABASE_URL_OWNER)" $(PG_OPTS) -f $<
	$(COMMAND) "$(DATABASE_URL_OWNER)" $(PG_OPTS) \
		-c "alter role app_loto_user with login password '$${APP_LOTO_USER_PASSWORD}' ;" \
		-c "alter role app_loto_admin with login password '$${APP_LOTO_ADMIN_PASSWORD}' ;"

_create_schemas: create_schemas.sql
	$(COMMAND) "$(DATABASE_URL_OWNER)" $(PG_OPTS) -f $<

_role_pls: pls.sql
	$(COMMAND) "$(DATABASE_URL_OWNER)" $(PG_OPTS) \
		-v user_local="$${USER}" \
		-f $<

_create_types_and_domains: create_types_and_domains.sql
	$(COMMAND) "$(DATABASE_URL_OWNER)" $(PG_OPTS) -f $<

_create_tables: create_tables.sql
	$(COMMAND) "$(DATABASE_URL_OWNER)" $(PG_OPTS) -f $<

_set_privileges: set_privileges.sql
	$(COMMAND) "$(DATABASE_URL_OWNER)" $(PG_OPTS) -f $<

_functions_app:
	make -C functions app

_functions_work:
	make -C functions work

reset: _create_roles _create_schemas _create_types_and_domains

build: _functions_app _create_tables _functions_work _set_privileges

prod: reset build

populate: populate.sql
	$(COMMAND) "$(DATABASE_URL_ADMIN)" $(PG_OPTS) \
		-f $<

nuke: nuke.sql
	sudo -u postgres $(PG) \
		-v user_local="$${USER}" \
		-f $<

.PHONY: all _create_roles _create_schemas _role_pls _create_types_and_domains \
	_create_tables _set_privileges _functions_app _functions_work \
	reset build prod populate nuke

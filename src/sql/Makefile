DB := lotoledger
PG := /usr/bin/env psql
DEBUG := # -e
PG_OPTS := -d $(DB) -v ON_ERROR_STOP=1 $(DEBUG)
BASENAME := /usr/bin/env basename

all: reset build populate

_dropdb:
	sudo -u postgres \
		dropdb $(DEBUG) --if-exists $(DB)

_create_roles: create_roles.sql
	sudo -u postgres $(PG) \
		-v ON_ERROR_STOP=1 \
		-f $<
	sudo -u postgres $(PG) \
		-v ON_ERROR_STOP=1 \
		-c "alter role app_loto_user with login password '$${APP_LOTO_USER_PASSWORD}' ;" \
		-c "alter role app_loto_admin with login password '$${APP_LOTO_ADMIN_PASSWORD}' ;"

_createdb: _dropdb _create_roles
	sudo -u postgres \
		createdb $(DEBUG) --owner app_loto_owner $(DB)

_create_schemas: create_schemas.sql
	sudo -u postgres $(PG) $(PG_OPTS) -f $<

_role_pls: pls.sql
	sudo -u postgres $(PG) $(PG_OPTS) \
		-v user_local="$${USER}" \
		-f $<

_create_types_and_domains: create_types_and_domains.sql
	sudo -u postgres $(PG) $(PG_OPTS) -f $<

_create_tables: create_tables.sql
	sudo -u postgres $(PG) $(PG_OPTS) -f $<

_set_privileges: set_privileges.sql
	sudo -u postgres $(PG) $(PG_OPTS) -f $<

_functions_app:
	make -C functions app

_functions_work:
	make -C functions work

reset: _createdb _create_schemas _role_pls _create_types_and_domains

build: _functions_app _create_tables _functions_work _set_privileges

populate: populate.sql
	$(PG) $(PG_OPTS) -U app_loto_admin \
		-f $<

nuke: nuke.sql
	sudo -u postgres $(PG) \
		-v user_local="$${USER}" \
		-f $<

.PHONY: all _dropdb _create_roles _createdb _role_pls _create_tables _set_privileges _functions_app _functions_work reset build populate nuke

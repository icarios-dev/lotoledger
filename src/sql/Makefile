DB := app_loto
PG := /usr/bin/env psql
DEBUG := # -e
PG_OPTS := -d $(DB) -v ON_ERROR_STOP=1 $(DEBUG)
BASENAME := /usr/bin/env basename
ASSETS_DIR := /home/bildoon/dev/loto/assets
SEED1 := $(ASSETS_DIR)/loto-1976-2008.csv
SEED2 := $(ASSETS_DIR)/loto-2008-2017.csv
SEED3 := $(ASSETS_DIR)/loto-2017-2019.csv
SEED4 := $(ASSETS_DIR)/loto-2019-2019.csv
SEED5 := $(ASSETS_DIR)/loto-2019-2025.csv

all:

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

_create_tables: create_tables.sql
	sudo -u postgres $(PG) $(PG_OPTS) -f $<

_set_privileges: set_privileges.sql
	sudo -u postgres $(PG) $(PG_OPTS) -f $<

_functions:
	make -C functions work

reset: _createdb _create_schemas _role_pls

build: _create_tables _set_privileges _functions

nuke: nuke.sql
	sudo -u postgres $(PG) \
		-v user_local="$${USER}" \
		-f $<

populate: populate.sql $(SEED1) $(SEED2) $(SEED3) $(SEED4) $(SEED5)
	$(PG) -U postgres -d $(DB) \
		-v ON_ERROR_STOP=1 \
		-v f1976_2008="'$(SEED1)'" -v s1976_2008=$(notdir $(SEED1)) \
		-v f2008_2017="'$(SEED2)'" -v s2008_2017=$(notdir $(SEED2)) \
		-v f2017_2019="'$(SEED3)'" -v s2017_2019=$(notdir $(SEED3)) \
		-v f2019_2019="'$(SEED4)'" -v s2019_2019=$(notdir $(SEED4)) \
		-v f2019_2025="'$(SEED5)'" -v s2019_2025=$(notdir $(SEED5)) \
		-f $<

.PHONY: all _dropdb _create_roles _createdb _role_pls _create_tables _set_privileges _functions reset build populate nuke

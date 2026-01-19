PG := /usr/bin/env psql
DB := app_loto
DEBUG := # -e
BASENAME := /usr/bin/env basename
ASSETS_DIR := /home/bildoon/dev/loto/assets
SEED1 := $(ASSETS_DIR)/loto-1976-2008.csv
SEED2 := $(ASSETS_DIR)/loto-2008-2017.csv
SEED3 := $(ASSETS_DIR)/loto-2017-2019.csv
SEED4 := $(ASSETS_DIR)/loto-2019-2019.csv
SEED5 := $(ASSETS_DIR)/loto-2019-2025.csv

all:

dropdb:
	sudo -u postgres \
		dropdb $(DEBUG) -U postgres --if-exists $(DB)

create_roles: create_roles.sql
	sudo -u postgres $(PG) -U postgres \
		-v ON_ERROR_STOP=1 \
		-v user_password="$${APP_LOTO_USER_PASSWORD}" \
		-v admin_password="$${APP_LOTO_ADMIN_PASSWORD}" \
		-f $<

createdb: dropdb create_roles
	sudo -u postgres \
		createdb $(DEBUG) -U postgres --owner app_loto_owner $(DB)

pls: pls.sql
	sudo -u postgres $(PG) -U postgres \
		-v ON_ERROR_STOP=1 \
		-v user_local="$${USER}" \
		-f $<

nuke: nuke.sql
	sudo -u postgres $(PG) -U postgres \
		-v user_local="$${USER}" -f $<

reset: createdb pls.sql

build: build.sql
	sudo -u postgres $(PG) -d $(DB) -f $<

populate: populate.sql $(SEED1) $(SEED2) $(SEED3) $(SEED4) $(SEED5)
	$(PG) -U postgres -d $(DB) \
		-v ON_ERROR_STOP=1 \
		-v f1976_2008="'$(SEED1)'" -v s1976_2008=$(notdir $(SEED1)) \
		-v f2008_2017="'$(SEED2)'" -v s2008_2017=$(notdir $(SEED2)) \
		-v f2017_2019="'$(SEED3)'" -v s2017_2019=$(notdir $(SEED3)) \
		-v f2019_2019="'$(SEED4)'" -v s2019_2019=$(notdir $(SEED4)) \
		-v f2019_2025="'$(SEED5)'" -v s2019_2025=$(notdir $(SEED5)) \
		-f $<

.PHONY: all dropdb create_roles createdb pls reset build populate

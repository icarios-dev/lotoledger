PG := /usr/bin/env psql
DB := app_loto
DEBUG :=  # -e
BASENAME := /usr/bin/env basename
ASSETS_DIR := /home/bildoon/dev/loto/assets
SEED1 := $(ASSETS_DIR)/loto-1976-2008.csv
SEED2 := $(ASSETS_DIR)/loto-2008-2017.csv
SEED3 := $(ASSETS_DIR)/loto-2017-2019.csv
SEED4 := $(ASSETS_DIR)/loto-2019-2019.csv
SEED5 := $(ASSETS_DIR)/loto-2019-2025.csv

all: reset build populate

reset:
	sudo -u postgres dropdb $(DEBUG) -U postgres --if-exists $(DB)
	sudo -u postgres dropuser $(DEBUG) -U postgres --if-exists $(DB)_owner
	sudo -u postgres dropuser $(DEBUG) -U postgres --if-exists $(DB)_admin
	sudo -u postgres dropuser $(DEBUG) -U postgres --if-exists $(DB)_user
	sudo -u postgres createdb $(DEBUG) -U postgres $(DB)

build: build.sql
	sudo -u postgres $(PG) -d $(DB) -f $<

populate: populate.pgsql $(FULLSEED1) $(FULLSEED2) $(FULLSEED3) $(FULLSEED4) $(FULLSEED5)
	$(PG) -U postgres -d $(DB) \
		-v ON_ERROR_STOP=1 \
		-v f1976_2008="'$(SEED1)'" -v s1976_2008=$(notdir $(SEED1)) \
		-v f2008_2017="'$(SEED2)'" -v s2008_2017=$(notdir $(SEED2)) \
		-v f2017_2019="'$(SEED3)'" -v s2017_2019=$(notdir $(SEED3)) \
		-v f2019_2019="'$(SEED4)'" -v s2019_2019=$(notdir $(SEED4)) \
		-v f2019_2025="'$(SEED5)'" -v s2019_2025=$(notdir $(SEED5)) \
		-f $<

.PHONY: all reset build populate

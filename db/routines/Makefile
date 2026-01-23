DB := lotoledger
PG := /usr/bin/env psql
LOCAL := sudo -u postgres $(PG)
PROD := $(PG)
COMMAND := $(PROD)
DATABASE_URL := $(DATABASE_URL_OWNER)
DEBUG := # -e
PG_OPTS := -v ON_ERROR_STOP=1 $(DEBUG)
app_files := app/*.sql
work_files := work/helpers.sql work/ingest_*.sql

define run_sql
	$(COMMAND) "$(DATABASE_URL)" $(PG_OPTS) $(addprefix -f , $^)
endef

all:

app: $(app_files)
	$(run_sql)

work: $(work_files)
	$(run_sql)

api:

.PHONY: all work api app

DB := app_loto
PG := /usr/bin/env psql
DEBUG := # -e
PG_OPTS := -d $(DB) -v ON_ERROR_STOP=1 $(DEBUG)
app_files := app.*.sql
work_files := work.helpers.sql work.ingest_*.sql

define run_sql
	sudo -u postgres $(PG) $(PG_OPTS) $(addprefix -f , $^)
endef

all:

app: $(app_files)
	$(run_sql)

work: $(work_files)
	$(run_sql)

api:

.PHONY: all work api

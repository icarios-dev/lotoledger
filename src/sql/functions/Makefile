DB := app_loto
PG := /usr/bin/env psql
DEBUG := # -e
PG_OPTS := -d $(DB) -v ON_ERROR_STOP=1 $(DEBUG)
work_files := work.normalize_draw_day.sql work.ingest_raw1.sql

define run_sql
	sudo -u postgres $(PG) $(PG_OPTS) $(addprefix -f , $^)
endef

all:

work: $(work_files)
	$(run_sql)

api:

.PHONY: all work api

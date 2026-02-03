build_api:
	docker build -t loto-api -f apps/api/Dockerfile --load .

run_api:
	docker run -p $(PORT):3000 -e DATABASE_URL_USER="$(DATABASE_URL_USER)" -e SECRET_KEY="$(SECRET_KEY)" loto-api

.PHONY: build_api run_api

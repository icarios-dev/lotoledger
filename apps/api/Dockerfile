# ---- Build stage ----
FROM erlang:28-alpine AS build

WORKDIR /build

# Récupère le binaire gleam (sans dépendre de l'OTP exact de cette image)
COPY --from=ghcr.io/gleam-lang/gleam:v1.14.0-erlang-alpine /bin/gleam /bin/gleam

# Copie uniquement l'app API depuis le monorepo
COPY apps/api /build/apps/api

WORKDIR /build/apps/api

# Produit une shipment exécutable
RUN gleam export erlang-shipment

# ---- Runtime stage ----
FROM erlang:28-alpine

WORKDIR /app

COPY --from=build /build/apps/api/build/erlang-shipment /app

ENV PORT=3000
EXPOSE 3000

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]

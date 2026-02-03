# ---- Build stage ----
FROM erlang:28-alpine AS build

WORKDIR /app

# Récupère le binaire gleam (sans dépendre de l'OTP exact de cette image)
COPY --from=ghcr.io/gleam-lang/gleam:v1.14.0-erlang-alpine /bin/gleam /bin/gleam

# Copie uniquement l'app API depuis le monorepo
COPY . .

# Produit une shipment exécutable
RUN gleam export erlang-shipment

# ---- Runtime stage ----
FROM erlang:28-alpine

WORKDIR /app

RUN ls -la && ls -la build || true && find . -maxdepth 3 -type d -name "erlang-shipment" -print
COPY --from=build /app/build/erlang-shipment /app

ENV PORT=3000
EXPOSE 3000

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]

import gleam/http.{Get}
import gleam/io
import gleam/json
import pog
import wisp.{type Request, type Response}

import infrastructure/logging
import modules/system/infrastructure/repo as system_repo
import modules/system/presentation/serializer.{healthy, ready_down, ready_ok}

pub fn home_page(req: Request) -> Response {
  // The home page can only be accessed via GET requests, so this middleware is
  // used to return a 405: Method Not Allowed response for all other methods.
  use <- wisp.require_method(req, Get)

  wisp.ok()
  |> wisp.html_body("<h1>Bienvenue sur LotoLedger!</h1>")
}

fn get_ready(db: pog.Connection) -> Response {
  case system_repo.ready(db) {
    Ok(True) -> {
      wisp.ok()
      |> wisp.json_body(ready_ok() |> json.to_string())
    }

    Ok(False) -> {
      wisp.response(503)
      |> wisp.json_body(ready_down() |> json.to_string())
    }

    Error(err) -> {
      io.println_error(logging.query_error_to_string(err))

      wisp.response(503)
      |> wisp.json_body(ready_down() |> json.to_string())
    }
  }
}

fn get_health() -> Response {
  wisp.ok()
  |> wisp.json_body(healthy() |> json.to_string())
}

pub fn handle_ready(req: Request, db) -> Response {
  use <- wisp.require_method(req, Get)
  get_ready(db)
}

pub fn handle_health(req: Request) -> Response {
  use <- wisp.require_method(req, Get)
  get_health()
}

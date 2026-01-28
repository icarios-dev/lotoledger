import gleam/http.{Get}
import gleam/io
import gleam/json
import pog
import wisp.{type Request, type Response}

import infrastructure/db_error_map
import infrastructure/logging
import interfaces/http/api_error
import modules/rulesets/infrastructure/repo as rulesets_repo
import modules/rulesets/presentation/contract.{RulesetsResponse}
import modules/rulesets/presentation/serializer as rulesets_serializer

fn get(db: pog.Connection) -> Response {
  case rulesets_repo.list(db) {
    Ok(pog.Returned(count, rows)) -> {
      let body =
        RulesetsResponse(count: count, rulesets: rows)
        |> rulesets_serializer.list_response()
        |> json.to_string()

      wisp.json_response(body, 200)
    }

    Error(err) -> {
      // log de l'erreur en console
      io.println_error(logging.query_error_to_string(err))
      // mapping erreur db -> erreur API
      let api_err = db_error_map.from_query_error(err)

      wisp.response(api_err.status)
      |> wisp.json_body(api_error.to_json(api_err) |> json.to_string())
    }
  }
}

pub fn handle_rulesets(req: Request, db: pog.Connection) -> Response {
  use <- wisp.require_method(req, Get)
  get(db)
}

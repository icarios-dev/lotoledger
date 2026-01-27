import gleam/io
import gleam/json
import pog
import wisp

import infrastructure/db_error_map
import infrastructure/logging
import interfaces/http/api_error
import modules/rulesets/infrastructure/repo as rulesets_repo
import modules/rulesets/presentation/contract.{RulesetsResponse}
import modules/rulesets/presentation/serializer as rulesets_serializer

pub fn rulesets(_, db: pog.Connection) -> wisp.Response {
  case rulesets_repo.list(db) {
    Ok(pog.Returned(count, rows)) -> {
      let body =
        RulesetsResponse(count: count, rulesets: rows)
        |> rulesets_serializer.list_response()
        |> json.to_string()

      wisp.json_response(body, 200)
    }

    Error(err) -> {
      io.println_error(logging.query_error_to_string(err))
      let api_err = db_error_map.from_query_error(err)

      let body = api_error.to_json(api_err) |> json.to_string()
      wisp.json_response(body, api_err.status)
    }
  }
}

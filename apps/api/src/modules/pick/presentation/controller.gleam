// HTTP / framework
import gleam/http.{Get}
import wisp.{type Request, type Response}

// Stdlib
import gleam/int
import gleam/io
import gleam/json
import gleam/result.{try}

// Infrastructure
import infrastructure/db_error_map
import infrastructure/logging
import pog

// HTTP helpers
import interfaces/http/api_error
import interfaces/http/bad_request
import interfaces/http/query.{type QueryListError}

// Domain
import modules/pick/domain/normalize.{type PickError, normalize_pick}
import modules/pick/domain/rules.{rule_std as rs}

// Repo
import modules/pick/infrastructure/repo

pub fn handle_pick_stats(req: Request, db: pog.Connection) -> Response {
  use <- wisp.require_method(req, Get)

  case
    {
      use nums <- try(parse_nums_from_query(req))
      use normalized <- try(normalize(nums))
      fetch(db, normalized)
    }
  {
    Ok(body) -> wisp.ok() |> wisp.json_body(body)
    Error(err) -> error_to_response(err)
  }
}

type PickStatsError {
  BadQuery(QueryListError)
  BadPick(PickError)
  Db(pog.QueryError)
}

fn parse_nums_from_query(req: Request) -> Result(List(Int), PickStatsError) {
  query.parse_int_list(req, "nums")
  |> result.map_error(BadQuery)
}

fn normalize(nums: List(Int)) -> Result(List(Int), PickStatsError) {
  normalize_pick(nums, rs.main_min, rs.main_max, rs.size_max)
  |> result.map_error(BadPick)
}

fn fetch(db: pog.Connection, nums: List(Int)) -> Result(String, PickStatsError) {
  repo.pick_stats(db, nums)
  |> result.map_error(Db)
}

fn error_to_response(err: PickStatsError) -> Response {
  case err {
    BadQuery(query.Missing) ->
      bad_request.bad_request("query_missing", "missing query parameter: nums")

    BadQuery(query.InvalidFormat) ->
      bad_request.bad_request(
        "query_invalid_format",
        "nums must be a comma-separated list of integers",
      )

    BadPick(normalize.EmptyPick) ->
      bad_request.bad_request("pick_empty", "Empty pick")

    BadPick(normalize.TooManyNumbers(max, got)) ->
      bad_request.bad_request(
        "pick_too_many_numbers",
        "Too many numbers: max "
          <> int.to_string(max)
          <> ", got "
          <> int.to_string(got),
      )

    BadPick(normalize.OutOfRange(min, max, got)) ->
      bad_request.bad_request(
        "pick_out_of_range",
        "Number "
          <> int.to_string(got)
          <> " out of range ("
          <> int.to_string(min)
          <> "-"
          <> int.to_string(max)
          <> ")",
      )

    Db(qe) -> {
      io.println_error(logging.query_error_to_string(qe))
      let api_err = db_error_map.from_query_error(qe)

      wisp.response(api_err.status)
      |> wisp.json_body(api_error.to_json(api_err) |> json.to_string())
    }
  }
}

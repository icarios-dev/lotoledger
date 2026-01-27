import gleam/int
import pog

pub fn query_error_to_string(err: pog.QueryError) -> String {
  case err {
    pog.ConstraintViolated(message, constraint, detail) ->
      "Constraint violated: "
      <> constraint
      <> " – "
      <> message
      <> " – "
      <> detail

    pog.PostgresqlError(code, name, message) ->
      "Postgres error " <> code <> " (" <> name <> "): " <> message

    pog.UnexpectedArgumentCount(expected, got) ->
      "Unexpected argument count: expected "
      <> int.to_string(expected)
      <> ", got "
      <> int.to_string(got)

    pog.UnexpectedArgumentType(expected, got) ->
      "Unexpected argument type: expected " <> expected <> ", got " <> got

    pog.UnexpectedResultType(_) -> "Unexpected result type"

    pog.QueryTimeout -> "Query timeout"

    pog.ConnectionUnavailable -> "Database connection unavailable"
  }
}

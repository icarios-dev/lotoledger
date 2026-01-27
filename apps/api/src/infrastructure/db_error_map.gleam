import interfaces/http/api_error.{type ApiError, ApiError}
import pog

pub fn from_query_error(err: pog.QueryError) -> ApiError {
  case err {
    // Erreurs "métier DB" explicites
    pog.ConstraintViolated(_, _, _) ->
      ApiError(
        status: 409,
        code: "constraint_violated",
        message: "Confilct",
        retryable: False,
      )

    // SQLSTATE: le jackpot pour faire du précis
    pog.PostgresqlError(code, _, _) -> from_sqlstate(code)

    // Erreurs de contrat repo<->SQL (bug côté serveur)
    pog.UnexpectedArgumentCount(_, _) ->
      ApiError(500, "server_bug_unexpected_argument_count", "Server bug", False)

    pog.UnexpectedArgumentType(_, _) ->
      ApiError(500, "server_bug_unexpected_argument_type", "Server bug", False)

    pog.UnexpectedResultType(_) ->
      ApiError(500, "server_bug_unexpected_result_type", "Server bug", False)

    // Infra
    pog.QueryTimeout -> ApiError(504, "db_timeout", "Database timeout", True)

    pog.ConnectionUnavailable ->
      ApiError(503, "db_unavailable", "Database unavailable", True)
  }
}

fn from_sqlstate(code: String) -> ApiError {
  case code {
    // AuthN / AuthZ
    "28P01" -> ApiError(401, "db_auth_failed", "Authentication failed", False)
    "28000" ->
      ApiError(401, "db_invalid_authorization", "Invalid authorization", False)
    "42501" -> ApiError(403, "db_permission_denied", "Permission denied", False)

    // Erreurs client (requête/paramètres)
    "22P02" ->
      ApiError(400, "invalid_text_representation", "Invalid Input", False)
    "22001" ->
      ApiError(400, "string_data_right_truncation", "Invalid Input", False)
    "22003" ->
      ApiError(400, "numeric_value_out_of_range", "Invalid Input", False)

    // Conflits / intégrité
    "23505" ->
      ApiError(409, "unique_violation", "Resource already exists", False)
    "23503" ->
      ApiError(409, "foreign_key_violation", "Invalid reference", False)
    "23502" ->
      ApiError(400, "not_null_violation", "Missing required field", False)
    "23514" -> ApiError(400, "check_violation", "Invalid value", False)

    // Concurrence / transactions
    "40001" -> ApiError(503, "serialization_failure", "Please retry", True)
    "40P01" -> ApiError(503, "deadlock_detected", "Please retry", True)

    // Fallback
    _ -> ApiError(500, "db_error", "Internal server error", False)
  }
}

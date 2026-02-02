import gleam/json

pub type ApiError {
  ApiError(status: Int, code: String, message: String, retryable: Bool)
}

pub fn to_json(err: ApiError) -> json.Json {
  json.object([
    #(
      "error",
      json.object([
        #("code", json.string(err.code)),
        #("message", json.string(err.message)),
      ]),
    ),
  ])
}

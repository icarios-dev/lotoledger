import gleam/json
import wisp.{type Response}

pub fn bad_request(code: String, message: String) -> Response {
  let body =
    json.object([
      #(
        "error",
        json.object([
          #("status", json.string("400")),
          #("code", json.string(code)),
          #("message", json.string(message)),
        ]),
      ),
    ])

  wisp.response(400)
  |> wisp.json_body(body |> json.to_string())
}

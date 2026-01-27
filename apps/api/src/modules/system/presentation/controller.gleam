import gleam/http.{Get}
import wisp.{type Request, type Response}

pub fn home_page(req: Request) -> Response {
  // The home page can only be accessed via GET requests, so this middleware is
  // used to return a 405: Method Not Allowed response for all other methods.
  use <- wisp.require_method(req, Get)

  wisp.ok()
  |> wisp.html_body("<h1>Bienvenue sur LotoLedger!</h1>")
}

pub fn health(req: Request, db) -> Response {
  use <- wisp.require_method(req, Get)
  wisp.ok()
  |> wisp.html_body("Healthy ?")
}

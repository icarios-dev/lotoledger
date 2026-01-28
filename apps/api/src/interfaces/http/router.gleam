import pog
import wisp.{type Request, type Response}

import interfaces/http/middleware
import modules/rulesets/presentation/controller.{handle_rulesets} as _
import modules/system/presentation/controller as sc

/// The HTTP request handler- your application!
///
pub fn handle_request(req: Request, db: pog.Connection) -> Response {
  // Apply the middleware stack for this request/response.
  use _req <- middleware.middleware(req)

  // Wisp doesn't have a special router abstraction, instead we recommend using
  // regular old pattern matching. This is faster than a router, is type safe,
  // and means you don't have to learn or be limited by a special DSL.
  //
  case wisp.path_segments(req) {
    // This matches `/`.
    [] -> sc.home_page(req)

    // This matches `/health`.
    ["health"] -> sc.handle_health(req)
    ["ready"] -> sc.handle_ready(req, db)

    // This matches `/rulesets`.
    // The `id` segment is bound to a variable and passed to the handler.
    ["rulesets"] -> handle_rulesets(req, db)

    // This matches all other paths.
    _ -> wisp.not_found()
  }
}

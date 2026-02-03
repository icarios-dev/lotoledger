import config/config
import interfaces/db/db
import interfaces/http/router
import mist
import wisp/wisp_mist

pub fn start() {
  let assert Ok(conf) = config.load()
  let secret_key_base = conf.secret_key
  let port = conf.port

  let handler = fn(request) { router.handle_request(request, db.handler()) }

  // Start the Mist web server.
  let assert Ok(_) =
    wisp_mist.handler(handler, secret_key_base)
    |> mist.new
    |> mist.port(port)
    |> mist.bind("0.0.0.0")
    |> mist.start
}

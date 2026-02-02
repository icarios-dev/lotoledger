import gleam/erlang/process
import interfaces/http/server
import wisp

pub fn main() {
  wisp.configure_logger()

  let _ = server.start()

  // The web server runs in new Erlang process, so put this one to sleep
  // while it works concurrently.
  process.sleep_forever()
}

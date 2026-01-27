import config/config
import gleam/erlang/process
import gleam/option.{type Option, None, Some}
import gleam/otp/static_supervisor as supervisor
import gleam/string
import pog

fn read_connection_uri(
  name: process.Name(pog.Message),
  database_url: String,
) -> Result(pog.Config, Nil) {
  case pog.url_config(name, database_url) {
    Ok(conf) -> Ok(apply_neon_endpoint_workaround(conf))
    Error(e) -> Error(e)
  }
}

fn apply_neon_endpoint_workaround(conf: pog.Config) -> pog.Config {
  // pog.Config expose host + connection_parameters, on va s'en servir. :contentReference[oaicite:1]{index=1}
  case neon_endpoint_id_from_host(conf.host) {
    Some(endpoint_id) -> {
      // On ajoute un paramètre Postgres "options" = "endpoint=<id>"
      // (c'est *pas* URL-encoded ici)
      pog.Config(..conf, connection_parameters: [
        #("options", "endpoint=" <> endpoint_id),
        ..conf.connection_parameters
      ])
    }
    None -> conf
  }
}

fn neon_endpoint_id_from_host(host: String) -> Option(String) {
  // Host Neon typique:
  // ep-xxxxx(-pooler).c-2.eu-central-1.aws.neon.tech
  // endpoint id attendu: ep-xxxxx
  case string.ends_with(host, ".neon.tech") {
    True ->
      case string.split(host, ".") {
        // premier label DNS = "ep-...." ou "ep-....-pooler"
        [first, ..] -> Some(strip_pooler_suffix(first))
        _ -> None
      }

    False -> None
  }
}

fn strip_pooler_suffix(label: String) -> String {
  case string.ends_with(label, "-pooler") {
    True -> {
      case string.split(label, "-pooler") {
        [base, ..] -> base
        _ -> label
      }
    }

    False -> label
  }
}

fn start_app_supervisor(config: pog.Config) {
  let db_child = pog.supervised(config)

  supervisor.new(supervisor.OneForOne)
  |> supervisor.add(db_child)
  |> supervisor.start
}

pub fn handler() -> pog.Connection {
  let assert Ok(conf) = config.load()

  let database_url = conf.database_url
  let db_pool_name = process.new_name("db_pool")

  let assert Ok(db_config) = read_connection_uri(db_pool_name, database_url)
  let assert Ok(_sup) = start_app_supervisor(db_config)

  pog.named_connection(db_pool_name)
}

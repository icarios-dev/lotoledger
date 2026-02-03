import envoy
import gleam/int
import gleam/result

pub type Config {
  // Config(port: Int, database_url: String, secret_key: String)
  Config(port: Int, secret_key: String, database_url: String)
}

pub fn load() -> Result(Config, String) {
  let port =
    envoy.get("PORT")
    |> result.unwrap("3000")
    |> int.parse
    |> result.unwrap(3000)

  use db <- result.try(
    envoy.get("DATABASE_URL_USER")
    |> result.map_error(fn(_) { "DATABASE_URL is missing" }),
  )

  use secret_key <- result.try(
    envoy.get("SECRET_KEY")
    |> result.map_error(fn(_) { "SECRET_KEY is missing" }),
  )

  Ok(Config(port: port, database_url: db, secret_key: secret_key))
}

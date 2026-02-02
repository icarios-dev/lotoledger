import gleam/json.{type Json}

pub fn ready_ok() -> Json {
  json.object([#("status", json.string("ok")), #("db", json.string("ok"))])
}

pub fn ready_down() -> Json {
  json.object([
    #("status", json.string("degraded")),
    #("db", json.string("down")),
  ])
}

pub fn healthy() -> Json {
  json.object([
    #("status", json.string("ok")),
    #("service", json.string("lotoledger")),
  ])
}

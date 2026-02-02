import gleam/dynamic/decode
import pog

pub fn ready(db: pog.Connection) -> Result(Bool, pog.QueryError) {
  let q =
    pog.query("select api.system__ready() ;")
    |> pog.returning(decode.at([0], decode.bool))

  case pog.execute(query: q, on: db) {
    Ok(pog.Returned(_, [ready, ..])) -> Ok(ready)
    Ok(_) -> Ok(False)
    Error(e) -> Error(e)
  }
}

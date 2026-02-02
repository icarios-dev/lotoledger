import gleam/dynamic/decode
import pog.{type Returned}

pub fn list(db: pog.Connection) -> Result(Returned(String), pog.QueryError) {
  let sql =
    pog.query("select rule_set from api.rulesets() ;")
    |> pog.returning(decode.at([0], decode.string))

  pog.execute(query: sql, on: db)
}

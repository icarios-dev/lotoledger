import gleam/dynamic/decode
import gleam/result
import pog

/// pour une sélection de numéro, renvoie des stats
///
pub fn pick_stats(
  db: pog.Connection,
  nums: List(Int),
) -> Result(String, pog.QueryError) {
  let row_decoder = {
    decode.at([0], decode.string)
  }

  use returned <- result.try(
    pog.query("select api.pick_stats_v1($1)::text as payload ;")
    |> pog.parameter(pog.array(pog.int, nums))
    |> pog.returning(row_decoder)
    |> pog.execute(db),
  )

  case returned {
    pog.Returned(_count, [payload, ..]) -> Ok(payload)
    pog.Returned(_count, []) -> Error(pog.UnexpectedResultType([]))
  }
}

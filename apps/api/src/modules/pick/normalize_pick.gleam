import gleam/int
import gleam/list
import gleam/result.{try}

// Tests à prévoir
//
// [] → EmptyPick
// [1,2,3,4,5,6] → TooManyNumbers
// [0] (si min=1) → OutOfRange
// [50] (si max=49) → OutOfRange
// [3,1,2] → Ok([1,2,3])
// [3,3,1] → Ok([1,3])

pub type PickError {
  EmptyPick
  TooManyNumbers(max: Int, got: Int)
  OutOfRange(min: Int, max: Int, got: Int)
}

fn validate_size(raw: List(Int), size_max: Int) -> Result(List(Int), PickError) {
  let size = list.length(raw)
  case size {
    0 -> Error(EmptyPick)
    size if size > size_max -> Error(TooManyNumbers(max: size_max, got: size))
    _ -> Ok(raw)
  }
}

fn validate_range(
  raw: List(Int),
  min: Int,
  max: Int,
) -> Result(List(Int), PickError) {
  case list.find(raw, fn(n) { n < min || n > max }) {
    Ok(bad) -> Error(OutOfRange(min: min, max: max, got: bad))
    Error(_) -> Ok(raw)
  }
}

// sort + uniq => canonical form
//
fn canonicalize(raw: List(Int)) -> List(Int) {
  let sorted = list.sort(raw, int.compare)
  // uniq on sorted list (stable, linear)
  list.fold(sorted, [], fn(acc, n) {
    case acc {
      [h, ..] if n == h -> acc
      _ -> [n, ..acc]
    }
  })
  |> list.reverse()
}

pub fn normalize_pick(
  raw raw: List(Int),
  min min: Int,
  max max: Int,
  size_max size_max: Int,
) -> Result(List(Int), PickError) {
  use raw <- try(validate_size(raw, size_max))
  use raw <- try(validate_range(raw, min, max))
  Ok(canonicalize(raw))
}

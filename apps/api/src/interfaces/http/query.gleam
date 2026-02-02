// HTTP / framework
import wisp.{type Request}

// Stdlib
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type QueryListError {
  Missing
  InvalidFormat
}

pub fn parse_int_list(
  req: Request,
  key: String,
) -> Result(List(Int), QueryListError) {
  get_all(req, key)
  |> build_query()
}

fn get_all(req: Request, key: String) -> List(String) {
  wisp.get_query(req)
  |> list.filter_map(fn(pair) {
    let #(k, v) = pair
    case k == key {
      True -> Ok(v)
      False -> Error(Nil)
    }
  })
}

fn build_query(values: List(String)) -> Result(List(Int), QueryListError) {
  case values {
    [] -> Error(Missing)
    _ -> {
      let raw = string.join(values, ",")
      case string.length(raw) < 32 {
        True -> {
          // values peut contenir "3,2,22" ou "3" "2" "22"
          values
          |> list.flat_map(fn(v) { string.split(v, on: ",") })
          |> list.map(string.trim)
          |> list.try_map(int.parse)
          |> result.replace_error(InvalidFormat)
        }
        False -> Error(InvalidFormat)
      }
    }
  }
}

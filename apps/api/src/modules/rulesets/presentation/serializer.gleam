import gleam/json.{type Json}
import modules/rulesets/presentation/contract.{type RulesetsResponse}

pub fn list_response(res: RulesetsResponse) -> Json {
  json.object([
    #("count", json.int(res.count)),
    #("rulesets", json.array(res.rulesets, json.string)),
  ])
}

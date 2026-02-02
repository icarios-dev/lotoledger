import gleam/option.{type Option}

pub type PickStatsV1 {
  PickStatsV1(pick: List(Int), draws: List(PickDraw), summary: PickSummary)
}

pub type PickDraw {
  PickDraw(date: String, main: List(Int), bonus: Option(Int))
}

pub type PickSummary {
  PickSummary(total_draws: Int, occurences: Int, pct_of_draws: Float)
}

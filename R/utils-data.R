check_raw <- function(data, game_name, method, chance, ...) {
  if (game_name == "变色魔块PRO") {
    data <- data |>
      filter(type == "go")
  }
  if (game_name == "图片记忆A") {
    data <- data |>
      filter(phase == "test")
  }
  # more 10% missed trials
  if (has_name(data, "acc") && mean(data$acc == -1) > 0.1) {
    return(FALSE)
  }
  if (method == "pc") {
    return(sum(data$acc == 1) > qbinom(0.95, nrow(data), chance))
  }
  if (method == "rt") {
    return(mean(data$rt < chance) < 0.1)
  }
}

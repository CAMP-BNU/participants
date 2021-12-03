#' Clean participants data
#'
#' @title
#' @param data_raw
#' @export
clean_participants <- function(data_raw) {
  data_raw |>
    select(matches("您")) |>
    rename_with(~ str_extract(.x, "(?<=您\\w{0,5}的)\\w+")) |>
    distinct() |>
    mutate(生日 = as.character(生日))
}

clean_participants_mikecrm <- function(data_raw) {
  data_raw |>
    select(姓名, 性别, 生日, 学号, 手机) |>
    mutate(across(c(生日, 手机, 学号), as.character))
}

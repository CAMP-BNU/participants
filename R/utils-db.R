pickup_glue <- function(file, ...) {
  read_file(file) |>
    str_glue(...) |>
    pickup()
}

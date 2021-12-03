library(targets)
source("R/clean_participants.R", encoding = "UTF-8")
tar_option_set(packages = "tidyverse")
list(
  tar_target(
    files_raw,
    "origin/BNU20211126.xlsx",
    format = "file"
  ),
  tar_target(
    data_raw,
    rio::import(files_raw, setclass = "tbl")
  ),
  tar_target(
    data_clean,
    clean_participants(data_raw),
  ),
  tar_target(
    data_grouping, {
      set.seed(1)
      data_clean |>
        slice_sample(prop = 1) |>
        mutate(g = row_number() %% 3) |>
        arrange(g, 姓名)
    }
  ),
  tar_target(
    files_clean,
    rio::export(
      data_grouping,
      fs::path("final", fs::path_file(files_raw)),
      overwrite = TRUE
    ),
    format = "file"
  )
)

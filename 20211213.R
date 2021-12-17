library(targets)
source("R/clean_participants.R", encoding = "UTF-8")
tar_option_set(packages = "tidyverse")
list(
  tar_target(
    files_raw,
    "origin/BNU20211213.xlsx",
    format = "file"
  ),
  tar_target(
    data_raw,
    rio::import(files_raw, range = "A2:G32", setclass = "tbl")
  ),
  tar_target(
    data_clean,
    clean_participants_mikecrm(data_raw),
  ),
  tar_target(
    data_grouping, {
      set.seed(1)
      data_clean |>
        slice_sample(prop = 1) |>
        mutate(
          年级 = "高三",
          班级 = str_c((row_number() - 1) %% 3 + 1, "班")
        )
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

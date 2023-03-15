library(targets)
tar_option_set(packages = "tidyverse")
school_name <- "天津师范大学"
list(
  tar_target(
    user_sql_tmpl,
    "sql/users_from_school_tmpl.sql",
    format = "file"
  ),
  tar_target(
    users_existed,
    read_file(user_sql_tmpl) |>
      str_glue() |>
      tarflow.iquizoo::pickup() |>
      mutate(user_dob = as.character(user_dob)),
    cue = tar_cue("always")
  ),
  tarchetypes::tar_file_read(
    subjs_from_tencent,
    "tjnu/校外被试信息收集.xlsx",
    read = readxl::read_excel(!!.x)
  ),
  tar_target(
    subjs_cols_corrected,
    subjs_from_tencent |>
      mutate(
        user_name = str_extract(`姓名（必填）`, "[\\p{Han}]+"),
        user_sex = `性别（必填）`,
        user_dob = as.character(`生日（必填）`)
      )
  ),
  tar_target(
    subjs_unmatched,
    subjs_cols_corrected |>
      anti_join(users_existed, by = join_by(user_name, user_sex, user_dob))
  ),
  tar_target(
    file_unmatched,
    writexl::write_xlsx(subjs_unmatched, "tjnu/unmatched.xlsx"),
    format = "file"
  )
)

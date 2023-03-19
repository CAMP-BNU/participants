library(targets)
tar_option_set(packages = c("tidyverse", "bit64", "tarflow.iquizoo"))
tar_source()
# used by `str_glue()`, might not be best practice
school_name <- "四川师范大学"
list(
  tarchetypes::tar_file_read(
    users_existed,
    "sql/users_from_school_tmpl.sql",
    read = pickup_glue(!!.x) |>
      mutate(user_dob = as.character(user_dob)),
    cue = tar_cue("always")
  ),
  tarchetypes::tar_file_read(
    subjs_signed_current,
    "sicnu/校外被试信息收集.xlsx",
    read = readxl::read_excel(!!.x)
  ),
  tar_target(
    subjs_signed,
    subjs_signed_current |>
      filter(
        row_number(desc(`提交时间（自动）`)) == 1,
        .by = `QQ号（必填）`
      )
  ),
  tar_target(
    subjs_cols_corrected,
    subjs_signed |>
      mutate(
        user_name = str_extract(`姓名（必填）`, "[\\p{Han}]+"),
        user_sex = `性别（必填）`,
        user_dob = as.character(`生日（必填）`),
        user_phone = `手机号（必填）`
      )
  ),
  tar_target(
    subjs_unmatched,
    subjs_cols_corrected |>
      anti_join(users_existed, by = join_by(user_name, user_sex, user_dob))
  ),
  tar_target(
    file_unmatched,
    writexl::write_xlsx(subjs_unmatched, "sicnu/unmatched.xlsx"),
    format = "file"
  ),
  tarchetypes::tar_file_read(
    users_progress,
    "sql/project_progress_tmpl.sql",
    read = pickup_glue(!!.x)
  ),
  tar_target(
    users_obsolete,
    users_progress |>
      filter(
        any(project_update_time < "2023-03-18" & project_progress > 0),
        .by = user_id
      ) |>
      distinct(user_id) |>
      pull(user_id)
  ),
  tarchetypes::tar_file_read(
    user_course_codes,
    "sql/course_codes_tmpl.sql",
    read = pickup_glue(!!.x),
    cue = tar_cue(mode = "always")
  ),
  tar_target(
    course_codes_valid,
    user_course_codes |>
      filter(str_detect(项目名称, "认知实验")) |>
      filter(!user_id %in% users_obsolete) |>
      select(-user_id)
  ),
  tar_target(
    file_course_codes,
    course_codes_valid |>
      mutate(
        参与须知 = str_glue(
          "欢迎参与实验！",
          "您本次实验课程码为：“{课程码}”。"
        ),
        .keep = "unused"
      ) |>
      group_split(项目名称) |>
      writexl::write_xlsx("sicnu/课程码.xlsx"),
    format = "file"
  )
)

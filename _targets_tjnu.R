library(targets)
tar_option_set(
  packages = c("tidyverse", "bit64", "tarflow.iquizoo", "openxlsx"),
  controller = crew::crew_controller_local(workers = 8)
)
tar_source()
# used by `str_glue()`, might not be best practice
school_name <- "天津师范大学"
school_name_en <- "tjnu"
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
    "tjnu/校外被试信息收集.xlsx",
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
      filter(`性别（必填）` == "男") |>
      anti_join(users_existed, by = join_by(user_name, user_sex, user_dob))
  ),
  tar_target(
    file_unmatched,
    writexl::write_xlsx(subjs_unmatched, "tjnu/unmatched.xlsx"),
    format = "file"
  ),
  tar_target(
    file_unmatched_tmpl,
    prepare_template_users(
      subjs_unmatched,
      grade = "2304级",
      class = "1班",
      out_dir = school_name_en
    )
  ),
  tarchetypes::tar_file_read(
    users_progress,
    "sql/project_progress_tmpl.sql",
    read = pickup_glue(!!.x),
    cue = tar_cue("always")
  ),
  tar_target(
    users_obsolete,
    users_progress |>
      filter(str_detect(project_name, "弃"), project_progress > 0) |>
      pull(user_id)
  ),
  tar_target(users_valid, filter(users_existed, !user_id %in% users_obsolete)),
  tarchetypes::tar_file_read(
    user_course_codes,
    "sql/course_codes_tmpl.sql",
    read = pickup_glue(!!.x),
    cue = tar_cue(mode = "always")
  ),
  tar_target(
    course_codes_valid,
    bind_rows(
      user_course_codes |>
        filter(!str_detect(项目名称, "弃"), str_detect(项目名称, "认知实验")),
      user_course_codes |>
        filter(项目名称 == "CAMP-补测（键盘）"),
      user_course_codes |>
        filter(项目名称 == "CAMP-补测（键盘）2") |>
        semi_join(
          targets::tar_read(makeup_completion2, store = "tjnu-data/_targets") |>
            filter(lengths(leftover) > 0),
          by = "user_id"
        ),
      user_course_codes |>
        filter(项目名称 == "CAMP-补测（语言）")
    ) |>
      inner_join(users_valid, by = "user_id")
  ),
  tar_target(
    file_course_codes,
    prepare_template_course_codes(course_codes_valid, school_name_en),
    format = "file"
  ),
  tar_target(
    users_progress_valid,
    prepare_progress_data(
      users_progress, users_valid,
      pattern = "^认知实验[A-E]$"
    )
  ),
  tar_target(
    file_progress,
    writexl::write_xlsx(users_progress_valid, "tjnu/progress.xlsx"),
    format = "file"
  )
)

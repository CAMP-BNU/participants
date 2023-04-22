library(targets)
tar_option_set(
  packages = c("tidyverse", "bit64", "tarflow.iquizoo", "openxlsx")
)
tar_source()
school_name <- "北京联合大学"
school_name_en <- "buu"
list(
  tarchetypes::tar_file_read(
    users_existed,
    "sql/users_from_school_tmpl.sql",
    read = pickup_glue(
      !!.x,
      .envir = rlang::env(school_name = school_name)
    ) |>
      mutate(user_dob = as.character(user_dob)),
    cue = tar_cue("always")
  ),
  tarchetypes::tar_file_read(
    subjs_signed_current,
    fs::path(school_name_en, "校外被试信息收集.xlsx"),
    read = readxl::read_excel(!!.x)
  ),
  tar_target(
    subjs_signed,
    subjs_signed_current |>
      filter(
        row_number(desc(`提交时间（自动）`)) == 1,
        .by = `QQ号（必填）`
      ) |>
      filter(`性别（必填）` == "男")
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
  tarchetypes::tar_file_read(
    users_progress_old,
    "sql/project_progress_tmpl.sql",
    read = pickup_glue(
      !!.x,
      .envir = rlang::env(school_name = "推理题目预实验")
    )
  ),
  tarchetypes::tar_file_read(
    users_old,
    "sql/users_from_school_tmpl.sql",
    read = pickup_glue(
      !!.x,
      .envir = rlang::env(school_name = "推理题目预实验")
    )
  ),
  tar_target(
    users_obsolete,
    users_progress_old |>
      filter(
        any(project_progress > 0),
        .by = user_id
      ) |>
      distinct(user_id) |>
      left_join(users_old, by = "user_id") |>
      select(user_name, user_sex, user_dob)
  ),
  tar_target(
    subjs_unmatched,
    subjs_cols_corrected |>
      anti_join(users_existed, by = join_by(user_name, user_sex, user_dob)) |>
      anti_join(users_obsolete, by = join_by(user_name, user_sex, user_dob))
  ),
  tar_target(
    file_unmatched,
    writexl::write_xlsx(
      subjs_unmatched,
      fs::path(school_name_en, "unmatched.xlsx")
    ),
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
    user_course_codes,
    "sql/course_codes_tmpl.sql",
    read = pickup_glue(!!.x, .envir = rlang::env(school_name = school_name)),
    cue = tar_cue(mode = "always")
  ),
  tar_target(
    course_codes_valid,
    user_course_codes |>
      filter(str_detect(项目名称, "认知实验"))
  ),
  tar_target(
    file_course_codes,
    prepare_template_course_codes(course_codes_valid, school_name_en),
    format = "file"
  ),
  tarchetypes::tar_file_read(
    users_progress,
    "sql/project_progress_tmpl.sql",
    read = pickup_glue(
      !!.x,
      .envir = rlang::env(school_name = school_name)
    )
  ),
  tar_target(
    users_progress_valid,
    users_existed |>
      inner_join(
        users_progress |>
          filter(str_detect(project_name, "^认知实验[A-E]$")) |>
          summarise(
            n = sum(project_progress) / 100,
            missed = str_c(
              project_name[project_progress < 100],
              collapse = ","
            ),
            .by = user_id
          ),
        by = "user_id"
      ) |>
      select(
        姓名 = user_name,
        性别 = user_sex,
        完成比例 = n,
        缺失的实验 = missed
      )
  ),
  tar_target(
    file_progress,
    writexl::write_xlsx(
      users_progress_valid,
      fs::path(school_name_en, "progress.xlsx")
    ),
    format = "file"
  )
)

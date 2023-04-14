prepare_template_course_codes <- function(course_codes_valid, out_dir) {
  projects <- unique(course_codes_valid$项目名称)
  wb <- loadWorkbook("tools/名单模板.xlsx")
  files <- str_glue("{out_dir}/名单模板_{projects}.xlsx")
  for (i in seq_along(projects)) {
    course_codes <- course_codes_valid |>
      filter(项目名称 == projects[[i]]) |>
      mutate(
        参与须知 = str_glue(
          "欢迎参与{项目名称}！",
          "课程码为：“{课程码}”。"
        )
      ) |>
      select(姓名, 手机号码, 参与须知)
    writeData(
      wb, "名单", course_codes,
      startCol = 2, startRow = 4, colNames = FALSE
    )
    saveWorkbook(wb, files[[i]], overwrite = TRUE)
  }
  files
}

prepare_template_users <- function(users, grade, class, out_dir) {
  file <- fs::path(
    out_dir,
    str_c("批量导入学生模板_", as.character(now(), "%Y%m%d_%H%M%S"), ".xlsx")
  )
  wb <- loadWorkbook("tools/批量导入学生模板.xlsx")
  data_users <- users |>
    transmute(
      姓名 = user_name,
      性别 = user_sex,
      生日 = user_dob,
      身份证号码 = "",
      学籍号 = "",
      手机号码 = user_phone,
      年级 = grade,
      班级 = class,
      班级类型 = "行政班"
    )
  writeData(wb, "Users", data_users, colNames = FALSE, startRow = 2)
  saveWorkbook(wb, file)
  file
}



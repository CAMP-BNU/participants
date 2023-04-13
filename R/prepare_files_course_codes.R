prepare_files_course_codes <- function(course_codes_valid, out_dir) {
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

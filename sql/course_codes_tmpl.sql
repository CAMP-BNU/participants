SELECT
  vo.OrganizationUserId user_id,
  c.`Name` 课程资源,
  pcc.`Name` 课程,
  vo.GradeName 分级,
  vo.ClassName 分班,
  vo.RealName 姓名,
  vo.Mobile 手机号码,
  pccc.UserCourseCode 课程码
FROM
  iquizoo_content_db.v_organizationuser vo
  INNER JOIN iquizoo_content_db.project_course_code_config pccc ON pccc.OrganizationUserId = vo.OrganizationUserId
  INNER JOIN iquizoo_content_db.project_course_config pcc ON pcc.Id = pccc.ProjectCourseConfigId
  INNER JOIN iquizoo_content_db.course c ON c.Id = pcc.CourseId
  INNER JOIN iquizoo_user_db.base_organization bo ON bo.Id = vo.OrganizationId
WHERE
  vo.OrganizationName = '{ school_name }';

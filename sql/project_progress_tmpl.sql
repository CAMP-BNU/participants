SELECT
  vo.OrganizationUserId user_id,
  vo.OrganizationName school,
  pcc.Name project_name,
  pcu.Progress project_progress
FROM
  iquizoo_content_db.project_course_user pcu
  INNER JOIN iquizoo_content_db.project_course_config pcc ON pcc.Id = pcu.ProjectCourseConfigId
  INNER JOIN iquizoo_content_db.v_organizationuser vo ON vo.OrganizationUserId = pcu.OrganizationUserId
WHERE vo.OrganizationName = '{ school_name }';

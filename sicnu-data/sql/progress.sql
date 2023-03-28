SELECT DISTINCT
    vo.OrganizationUserId user_id,
    pcc.`Name` project,
    pcu.Progress progress
FROM
    iquizoo_content_db.v_organizationuser vo
    INNER JOIN iquizoo_content_db.project_course_user pcu ON pcu.OrganizationUserId = vo.OrganizationUserId
    INNER JOIN iquizoo_content_db.project_course_config pcc ON pcc.Id = pcu.ProjectCourseConfigId
WHERE
	vo.OrganizationName = '四川师范大学'
	AND pcc.Name IN ('认知实验A', '认知实验B', '认知实验C', '认知实验D', '认知实验E');

SELECT DISTINCT
  v_organizationuser.OrganizationUserId user_id,
  v_organizationuser.RealName user_name,
  CASE v_organizationuser.Gender
    WHEN 1 THEN '男'
    WHEN 2 THEN '女'
    ELSE '未知'
  END user_sex,
  DATE_FORMAT(v_organizationuser.Birthday, '%Y-%m-%d') user_dob,
  v_organizationuser.Mobile user_phone
FROM
  iquizoo_content_db.v_organizationuser
WHERE
  v_organizationuser.OrganizationName = '{ school_name }';

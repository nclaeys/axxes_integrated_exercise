resource "aws_iam_group" "group" {
  name = var.participants_permissions.group
}

resource "aws_iam_policy" "integrated_exercise_participants_s3_group_policy" {
  name = "${aws_iam_group.group.name}-s3-read-access-policy"
  policy = data.aws_iam_policy_document.integrated_exercise_s3_access.json
}

resource "aws_iam_group_policy_attachment" "integrated_exercise_participants_s3_group_policy_attachment" {
  group = aws_iam_group.group.name
  policy_arn = aws_iam_policy.integrated_exercise_participants_s3_group_policy.arn
}

resource "aws_iam_group_policy_attachment" "integrated_exercise_participants_sm_role_group_policy" {
  group = aws_iam_group.group.name
  policy_arn = aws_iam_policy.sm_role_policy.arn
}

resource "aws_iam_policy" "sm_role_policy" {
  policy = data.aws_iam_policy_document.integrated_exercise_secret_read_access.json
  name = "${var.environment}-sm-role-group-policy"
}

resource "aws_iam_policy" "mwaa_role_policy" {
  policy = data.aws_iam_policy_document.integrated_exercise_mwaa_access.json
  name = "${var.environment}-mwaa-role-group-policy"
}

resource "aws_iam_group_policy_attachment" "integrated_exercise_participants_mwaa_role_group_policy" {
  group = aws_iam_group.group.name
  policy_arn = aws_iam_policy.mwaa_role_policy.arn
}

resource "aws_iam_group_policy" "integrated_exercise_participants_batch_group_policy" {
  group = aws_iam_group.group.name
  name = "${aws_iam_group.group.name}-batch-access"
  policy = data.aws_iam_policy_document.integrated_exercise_batch_access.json
}

resource "aws_iam_group_policy_attachment" "integrated_exercise_participants_ecr_role_group_policy" {
  group = aws_iam_group.group.name
  policy_arn = aws_iam_policy.ecr_policy.arn
}

resource "aws_iam_group_policy" "integrated_exercise_participants_pass_batch_role_group_policy" {
  group = aws_iam_group.group.name
  name = "${aws_iam_group.group.name}-pass-batch-role"
  policy = data.aws_iam_policy_document.pass_batch_job_role.json
}

resource "aws_iam_policy" "integrated_exercise_participants_pass_mwaa_role_policy" {
  name = "${aws_iam_group.group.name}-pass-mwaa-role-policy"
  policy = data.aws_iam_policy_document.pass_mwaa_role.json
}

resource "aws_iam_group_policy_attachment" "integrated_exercise_participants_pass_mwaa_role_group_policy" {
  group = aws_iam_group.group.name
  policy_arn = aws_iam_policy.integrated_exercise_participants_pass_mwaa_role_policy.arn
}

resource "aws_iam_group_policy" "integrated_exercise_participants_ssm_role_group_policy" {
  group = aws_iam_group.group.name
  name = "${aws_iam_group.group.name}-ssm-access"
  policy = data.aws_iam_policy_document.parameter_store_access.json
}
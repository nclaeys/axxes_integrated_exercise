resource "aws_iam_role" "job_role" {
  name = "${var.environment}-batch-job-role"
  path = "/${var.environment}/"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach S3 policy to project role
resource "aws_iam_role_policy" "s3_policy" {
  name = "s3_policy"
  policy = data.aws_iam_policy_document.integrated_exercise_s3_access.json
  role = aws_iam_role.job_role.id
}

resource "aws_iam_role_policy" "secret_manager" {
  name = "secret_policy"
  policy = data.aws_iam_policy_document.integrated_exercise_secret_read_access.json
  role = aws_iam_role.job_role.id
}

resource "aws_iam_role_policy_attachment" "preprocessor_pipeline_role_cloudwatch_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchEventsFullAccess"
  role       = aws_iam_role.job_role.name
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.job_role.name
}

data "aws_iam_policy_document" "additional_batch_s3_access" {
  statement {
    actions = [
      "s3:*Put*",
      "s3:*Get*",
      "s3:*Delete*"
    ]
    resources = [
      "arn:aws:s3:::${local.s3_bucket}",
      "arn:aws:s3:::${local.s3_bucket}/*",
    ]
  }
}

resource "aws_iam_role_policy" "additional_batch_s3" {
  policy = data.aws_iam_policy_document.additional_batch_s3_access.json
  role = aws_iam_role.job_role.id
  name = "batch-additional-s3-read-access"

}

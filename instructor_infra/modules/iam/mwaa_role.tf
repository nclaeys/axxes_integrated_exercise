resource "aws_iam_role" "mwaa_role" {
  name = "${var.environment}-mwaa-role"
  path = "/${var.environment}/"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": ["airflow.amazonaws.com","airflow-env.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "mwaa_role_policy" {
    statement {
    actions = [
      "batch:SubmitJob",
    ]
    resources = [
      "arn:aws:batch:${var.region}:${var.account_id}:job-queue/${var.batch_job_queue}",
      "arn:aws:batch:${var.region}:${var.account_id}:job-definition/*",
      "arn:aws:batch:${var.region}:${var.account_id}:job/*"
    ]
  }
  statement {
    actions = [
      "s3:*Get*",
      "s3:*List*"
    ]
    resources = [
      "arn:aws:s3:::${local.s3_bucket}/*",
      "arn:aws:s3:::${local.s3_bucket}",
      "arn:aws:s3:::${local.s3_bucket}/*/${local.s3_dags_folder}/*",
    ]
  }
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:GetLogRecord",
      "logs:GetLogGroupFields",
      "logs:GetQueryResults"]
    resources = [
      "arn:aws:logs:${var.region}:${var.account_id}:log-group:airflow-*"]
  }
  statement {
    actions = [
      "logs:DescribeLogGroups"
    ]
    resources = [
      "*"]
  }

  statement {
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
      "sqs:SendMessage"]
    resources = [
      "arn:aws:sqs:${var.region}:*:airflow-celery-*"]
  }
  statement {
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:Encrypt"]
    not_resources = ["arn:aws:kms:${var.region}:${var.account_id}:key/*"]
    condition {
      test = "StringLike"
      values = ["sqs.eu-west-1.amazonaws.com"]
      variable = "kms:ViaService"
    }
  }
}

resource "aws_iam_policy" "mwaa_policy" {
  policy = data.aws_iam_policy_document.mwaa_role_policy.json
  name = "${aws_iam_group.group.name}-mwaa-policy"
}
resource "aws_iam_role_policy_attachment" "mwaa_batch_iam_policy" {
  policy_arn = aws_iam_policy.mwaa_policy.arn
  role = aws_iam_role.mwaa_role.name
}

resource "aws_iam_role_policy" "integrated_exercise_mwaa_s3_access" {
  role = aws_iam_role.mwaa_role.id
  name = "${aws_iam_group.group.name}-mwaa-s3-access"
  policy = data.aws_iam_policy_document.integrated_exercise_s3_access.json
}

resource "aws_iam_role_policy_attachment" "mwaa_cloudwatch_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchEventsFullAccess"
  role = aws_iam_role.mwaa_role.name
}

resource "aws_iam_role_policy" "integrated_exercise_mwaa_batch_access" {
  role = aws_iam_role.mwaa_role.id
  name = "${aws_iam_group.group.name}-mwaa-batch-access"
  policy = data.aws_iam_policy_document.integrated_exercise_batch_access.json
}
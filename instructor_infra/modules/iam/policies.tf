locals {
  s3_bucket = var.participants_permissions.s3_access.bucket
  s3_dags_folder = var.participants_permissions.s3_access.dags_folder
}

data "aws_iam_policy_document" "integrated_exercise_s3_access" {
  statement {
    actions = [
      "s3:*Get*"]
    resources = [
      "arn:aws:s3:::${local.s3_bucket}/*",
      "arn:aws:s3:::${local.s3_bucket}/${local.s3_dags_folder}/*",
    ]
  }
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:GetEncryptionConfiguration"]
    resources = [
      "arn:aws:s3:::${local.s3_bucket}"]
  }
  statement {
    actions = [
      "s3:ListAllMyBuckets"]
    resources = [
      "*"]
  }
  statement {
    actions = [
      "s3:*PutObject*",
      "s3:*DeleteObject*"
    ]
    resources = [
      "arn:aws:s3:::${local.s3_bucket}/${local.s3_dags_folder}/*",
      "arn:aws:s3:::${local.s3_bucket}/${local.s3_dags_folder}",
      "arn:aws:s3:::${local.s3_bucket}/*",
    ]
  }
  statement {
    actions = [
      "s3:GetAccountPublicAccessBlock"]
    resources = [
      "*"]
  }
  statement {
    actions = [
      "s3:GetBucketPublicAccessBlock"]
    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "integrated_exercise_secret_read_access" {
  statement {
    actions = [
      "secretsmanager:ListSecrets"]
    resources = [
      "*"]
  }
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"]
    resources = [
      "arn:aws:secretsmanager:*:*:secret:${var.participants_permissions.secret_access.secret}*"]
  }
}

data "aws_iam_policy_document" "integrated_exercise_mwaa_access" {
  statement {
    actions = [
      "airflow:GetEnvironment",
    ]
    resources = [
      "arn:aws:airflow:${var.region}:${var.account_id}:environment/*"]
    condition {
      test = "StringEquals"
      values = [
        var.environment]
      variable = "aws:ResourceTag/environment"
    }
  }
  statement {
    actions = [
      "airflow:CreateEnvironment",
      "airflow:DeleteEnvironment",
      "airflow:TagResource",
      "airflow:UnTagResource",
      "airflow:UpdateEnvironment"
    ]
    resources = [
      "arn:aws:airflow:${var.region}:${var.account_id}:environment/$${aws:username}*",
      "arn:aws:airflow:${var.region}:${var.account_id}:environment/*",
    ]
    condition {
      test = "StringEquals"
      values = [
        var.environment]
      variable = "aws:ResourceTag/environment"
    }
  }
  statement {
    actions = [
      "airflow:CreateWebLoginToken"
    ]
    resources = [
      "arn:aws:airflow:eu-west-1:${var.account_id}:role/*"]
  }
  statement {
    actions = [
      "airflow:ListEnvironments"]
    resources = [
      "arn:aws:airflow:${var.region}:${var.account_id}:*"]
  }
  statement {
    actions = [
      "ec2:DescribeVpcs",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets"]
    resources = [
      "*"]
  }
  statement {
    actions = [
      "ec2:CreateNetworkInterface"
    ]
    resources = [
      "arn:aws:ec2:${var.region}:${var.account_id}:subnet/*",
      "arn:aws:ec2:${var.region}:${var.account_id}:network-interface/*"]
  }
  statement {
    actions = [
      "ec2:CreateVpcEndpoint"]
    resources = [
      "arn:aws:ec2:${var.region}:${var.account_id}:vpc-endpoint/*",
      "arn:aws:ec2:${var.region}:${var.account_id}:vpc/*",
      "arn:aws:ec2:${var.region}:${var.account_id}:subnet/*",
      "arn:aws:ec2:${var.region}:${var.account_id}:security-group/*"]
  }
  statement {
    actions = [
      "logs:GetLogEvents",
      "logs:DescribeLogStreams"
    ]
    resources = [
      "arn:aws:logs:eu-west-1:${var.account_id}:log-group:airflow*:log-stream:*"]
  }
}

data "aws_iam_policy_document" "integrated_exercise_batch_access" {
  statement {
    actions = [
      "batch:DescribeJobQueues",
      "batch:DescribeJobs",
      "batch:DescribeJobDefinitions",
      "batch:ListJobs",
      "batch:DescribeComputeEnvironments",
      "batch:ListSchedulingPolicies"
    ]
    resources = [
      "*"]
  }
  statement {
    actions = [
      "batch:SubmitJob",
      "batch:TagResource",
      "batch:RegisterJobDefinition",
      "batch:DeregisterJobDefinition"
    ]
    resources = [
      "arn:aws:batch:${var.region}:${var.account_id}:job-queue/${var.batch_job_queue}",
      "arn:aws:batch:${var.region}:${var.account_id}:job-definition/$${aws:username}*",
      "arn:aws:batch:${var.region}:${var.account_id}:job/$${aws:username}*"
    ]
    condition {
      test = "StringEquals"
      values = [
        var.environment]
      variable = "aws:ResourceTag/environment"
    }
  }
  statement {
    actions = [
      "logs:GetLogEvents",
      "logs:DescribeLogStreams"
    ]
    resources = [
      "arn:aws:logs:eu-west-1:${var.account_id}:log-group:/aws/batch/job:log-stream:*"]
  }
  statement {
    actions = [
      "logs:DescribeLogGroups"]
    resources = [
      "arn:aws:logs:eu-west-1:${var.account_id}:log-group::log-stream:"]
  }
}

data "aws_iam_policy_document" "integrated_exercise_ecr_access" {
  statement {
    actions = [
      "ecr:CreateRepository",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:BatchDeleteImage",
      "ecr:ListImages",
      "ecr:DeleteRepository",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability",
      "ecr:ListTagsForResource",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"]
    resources = [
      "arn:aws:ecr:${var.region}:${var.account_id}:repository/*"]
  }
  statement {
    actions = [
      "ecr:DescribeRepositories",
    ]
    resources = [
      "arn:aws:ecr:${var.region}:${var.account_id}:repository/*"]
  }
  statement {
    actions = [
      "ecr:GetAuthorizationToken"]
    resources = [
      "*"]
  }
}

resource "aws_iam_policy" "ecr_policy" {
  policy = data.aws_iam_policy_document.integrated_exercise_ecr_access.json
  name = "${var.environment}-ecr-group-policy"
}

data "aws_iam_policy_document" "pass_batch_job_role" {
  statement {
    actions = [
      "iam:GetRole",
      "iam:PassRole"]
    resources = [
      aws_iam_role.job_role.arn]
  }
  statement {
    actions = [
      "iam:ListRoles"]
    resources = [
      "*"]
  }
}

data "aws_iam_policy_document" "pass_mwaa_role" {
  statement {
    actions = [
      "iam:GetRole",
      "iam:PassRole"]
    resources = [
      aws_iam_role.mwaa_role.arn]
  }
  statement {
    actions = [
      "iam:ListRoles"]
    resources = [
      "*"]
  }
}

data "aws_iam_policy_document" "parameter_store_access" {
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters"]
    resources = [
      "arn:aws:ssm:${var.region}:${var.account_id}:parameter/${var.environment}/*"]
  }
}
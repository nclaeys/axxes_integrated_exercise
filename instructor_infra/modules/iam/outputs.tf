output "mwaa_role_arn" {
  value = aws_iam_role.mwaa_role.arn
}

output "batch_job_role_arn" {
  value = aws_iam_role.job_role.arn
}

output "iam_group_participants" {
  value = aws_iam_group.group.name
}
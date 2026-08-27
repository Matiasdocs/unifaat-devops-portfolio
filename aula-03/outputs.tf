output "iam_users" {
  description = "Usuarios IAM criados"

  value = [
    aws_iam_user.juliana_dev.name,
    aws_iam_user.rafael_platform.name,
    aws_iam_user.lucas_intern.name
  ]
}

output "iam_groups" {
  description = "Grupos IAM criados"

  value = [
    aws_iam_group.developers.name,
    aws_iam_group.platform_eng.name
  ]
}

output "policy_arns" {
  description = "ARNs das policies IAM criadas"

  value = [
    aws_iam_policy.s3_read.arn,
    aws_iam_policy.ec2_s3_full.arn,
    aws_iam_policy.deny_destructive.arn,
    aws_iam_policy.ec2_s3_app_data.arn
  ]
}

output "ec2_role_arn" {
  description = "ARN da service role utilizada pelo EC2"
  value       = aws_iam_role.ec2_role.arn
}

output "instance_profile_name" {
  description = "Nome do instance profile"
  value       = aws_iam_instance_profile.ec2_profile.name
}
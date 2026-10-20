module "ecr_repository" {
  source = "../../"

  region = var.region

  component = var.component

  repository_name = var.repository_name

  allow_in_account_lambda_pull_access = true
  allow_cross_account_lambda_pull_access = true
  allowed_cross_account_lambda_pull_access_account_ids = var.allowed_lambda_account_ids

  allow_role_based_pull_access = true
  allowed_role_based_pull_access_role_arns = [
    time_sleep.wait_for_role_propagation.triggers["role1_arn"],
    time_sleep.wait_for_role_propagation.triggers["role2_arn"]
  ]
}

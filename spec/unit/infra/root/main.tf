module "ecr_repository" {
  source = "../../../.."

  region = var.region

  component = var.component

  repository_name = var.repository_name

  repository_force_delete = var.repository_force_delete

  repository_image_tag_mutability        = var.repository_image_tag_mutability
  repository_image_scanning_scan_on_push = var.repository_image_scanning_scan_on_push

  tags = var.tags

  allow_in_account_lambda_pull_access    = var.allow_in_account_lambda_pull_access
  allow_cross_account_lambda_pull_access = var.allow_cross_account_lambda_pull_access
  allow_role_based_pull_access           = var.allow_role_based_pull_access

  allowed_cross_account_lambda_pull_access_account_ids = var.allowed_cross_account_lambda_pull_access_account_ids
  allowed_role_based_pull_access_role_arns             = var.allowed_role_based_pull_access_role_arns
}

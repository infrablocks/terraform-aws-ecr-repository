locals {
  # default for cases when `null` value provided, meaning "use default"
  allow_in_account_lambda_pull_access                  = var.allow_in_account_lambda_pull_access == null ? false : var.allow_in_account_lambda_pull_access
  allow_cross_account_lambda_pull_access               = var.allow_cross_account_lambda_pull_access == null ? false : var.allow_cross_account_lambda_pull_access
  allow_role_based_pull_access                         = var.allow_role_based_pull_access == null ? false : var.allow_role_based_pull_access
  allowed_cross_account_lambda_pull_access_account_ids = var.allowed_cross_account_lambda_pull_access_account_ids == null ? [] : var.allowed_cross_account_lambda_pull_access_account_ids
  allowed_role_based_pull_access_role_arns             = var.allowed_role_based_pull_access_role_arns == null ? [] : var.allowed_role_based_pull_access_role_arns
}

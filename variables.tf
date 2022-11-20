variable "region" {
  description = "The region in which to create the ECR repository."
  type        = string
}

variable "repository_name" {
  description = "The repository name to use for the ECR repository."
  type = string
}

variable "allow_in_account_lambda_access" {
  type = bool
  default = false
}
variable "allow_cross_account_lambda_access" {
  type = bool
  default = false
}
variable "allowed_cross_account_lambda_access_accounts" {
  type = list(string)
  default = []
}

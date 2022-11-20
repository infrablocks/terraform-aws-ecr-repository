variable "region" {}

variable "repository_name" {}

variable "allow_in_account_lambda_access" {
  type = bool
  default = null
}
variable "allow_cross_account_lambda_access" {
  type = bool
  default = null
}
variable "allowed_cross_account_lambda_access_accounts" {
  type = list(string)
  default = null
}

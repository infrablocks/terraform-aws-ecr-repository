variable "region" {}

variable "component" {}
variable "deployment_identifier" {}

variable "repository_name" {}

variable "allowed_lambda_account_ids" {
  type = list(string)
}

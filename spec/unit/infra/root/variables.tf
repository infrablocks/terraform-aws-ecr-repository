variable "region" {}

variable "repository_name" {}

variable "repository_force_delete" {
  type = bool
  default = null
}
variable "repository_image_tag_mutability" {
  default = null
}
variable "repository_image_scanning_scan_on_push" {
  type = bool
  default = null
}

variable "allow_in_account_lambda_pull_access" {
  type = bool
  default = null
}
variable "allow_cross_account_lambda_pull_access" {
  type = bool
  default = null
}
variable "allow_role_based_pull_access" {
  type = bool
  default = null
}

variable "allowed_cross_account_lambda_pull_access_account_ids" {
  type = list(string)
  default = null
}
variable "allowed_role_based_pull_access_role_arns" {
  type = list(string)
  default = null
}

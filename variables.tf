variable "region" {
  description = "The region in which to create the ECR repository."
  type        = string
}

variable "component" {
  description = "The name of the component or service for which this repository exists."
  type        = string
}

variable "repository_name" {
  description = "The repository name to use for the ECR repository."
  type = string
}

variable "repository_force_delete" {
  description = "If true, will delete the repository even if it contains images. Defaults to false."
  type = bool
  default = false
  nullable = false
}
variable "repository_image_tag_mutability" {
  description = "The tag mutability setting for the repository. Must be one of: MUTABLE or IMMUTABLE. Defaults to IMMUTABLE."
  type = string
  default = "IMMUTABLE"
  nullable = false
}
variable "repository_image_scanning_scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false). Defaults to true"
  type = bool
  default = true
  nullable = false
}

variable "tags" {
  description = "AWS tags to use on created infrastructure components"
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "allow_in_account_lambda_pull_access" {
  type = bool
  default = false
  nullable = false
}
variable "allow_cross_account_lambda_pull_access" {
  type = bool
  default = false
  nullable = false
}
variable "allow_role_based_pull_access" {
  type = bool
  default = false
  nullable = false
}

variable "allowed_cross_account_lambda_pull_access_account_ids" {
  type = list(string)
  default = []
  nullable = false
}
variable "allowed_role_based_pull_access_role_arns" {
  type = list(string)
  default = []
  nullable = false
}

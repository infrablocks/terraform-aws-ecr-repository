module "ecr_repository" {
  # This makes absolutely no sense. I think there's a bug in terraform.
  source = "./../../../../../../../"

  repository_name = var.repository_name
}

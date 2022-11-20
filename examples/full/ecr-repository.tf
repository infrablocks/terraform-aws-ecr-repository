module "ecr_repository" {
  source = "../../"

  region = var.region

  repository_name = var.repository_name
}

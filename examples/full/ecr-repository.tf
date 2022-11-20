module "ecr_repository" {
  source = "../../"

  region = var.region

  component = var.component

  repository_name = var.repository_name
}

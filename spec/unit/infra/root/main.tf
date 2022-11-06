module "ecr_repository" {
  source = "../../../.."

  repository_name = var.repository_name
}

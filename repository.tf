resource "aws_ecr_repository" "repository" {
  name = var.repository_name

  force_delete = var.repository_force_delete

  image_tag_mutability = var.repository_image_tag_mutability
}

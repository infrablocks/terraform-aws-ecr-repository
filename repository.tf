resource "aws_ecr_repository" "repository" {
  name = var.repository_name

  force_delete = var.repository_force_delete

  image_tag_mutability = var.repository_image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.repository_image_scanning_scan_on_push
  }

  tags = merge(local.resolved_tags, {
    Name: var.repository_name
  })
}

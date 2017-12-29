output "registry_id" {
  description = "The account ID of the registry holding the repository."
  value = "${aws_ecr_repository.repository.registry_id}"
}
output "repository_url" {
  description = "The URL of the repository."
  value = "${aws_ecr_repository.repository.repository_url}"
}

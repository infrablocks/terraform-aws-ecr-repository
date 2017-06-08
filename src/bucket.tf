resource "aws_s3_bucket" "infrastructure_events" {
  bucket = "${var.bucket_name_prefix}-${var.region}-${var.deployment_identifier}"
  region = "${var.region}"

  tags {
    Name = "${var.bucket_name_prefix}-${var.region}-${var.deployment_identifier}",
    Component = "common"
    DeploymentIdentifier = "${var.deployment_identifier}"
  }
}
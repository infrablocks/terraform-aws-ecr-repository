data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "infrastructure_events_topic" {
 "statement" {
   actions = ["SNS:Publish"]
   effect = "Allow"
   resources = [
     "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:${var.topic_name_prefix}-${var.region}-${var.deployment_identifier}"
   ]

   condition {
     test = "ArnLike"
     values = ["${aws_s3_bucket.infrastructure_events.arn}"]
     variable = "aws:SourceArn"
   }

   principals {
     identifiers = ["s3.amazonaws.com"]
     type = "Service"
   }
 }
}

resource "aws_sns_topic" "infrastructure_events" {
  name = "${var.topic_name_prefix}-${var.region}-${var.deployment_identifier}"
  display_name = "${var.topic_name_prefix}-${var.region}-${var.deployment_identifier}"
  policy = "${data.aws_iam_policy_document.infrastructure_events_topic.json}"
}

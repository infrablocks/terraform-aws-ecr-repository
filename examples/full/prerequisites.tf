data "aws_iam_policy_document" "assume_role_policy_document" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "role1" {
  name = "role1-${var.component}-${var.deployment_identifier}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_document.json
}

resource "aws_iam_role" "role2" {
  name = "role2-${var.component}-${var.deployment_identifier}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_document.json
}

resource "time_sleep" "wait_for_role_propagation" {
  create_duration = "15s"

  triggers = {
    role1_arn = aws_iam_role.role1.arn
    role2_arn = aws_iam_role.role2.arn
  }
}

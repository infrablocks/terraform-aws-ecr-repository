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

resource "aws_iam_role" "test1" {
  name = "test1"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_document.json
}

resource "aws_iam_role" "test2" {
  name = "test2"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_document.json
}

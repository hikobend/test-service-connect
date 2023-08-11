# ECSタスクロール
data "aws_iam_policy_document" "ecs_task_doc" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "task_role" {
  name               = "nginx-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_doc.json
}

data "aws_iam_policy_document" "ecs_exec_doc" {
  ## SSMサービス関連のアクセス許可
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_exec_policy" {
  name   = "AmazonECSExecPolicy"
  policy = data.aws_iam_policy_document.ecs_exec_doc.json
}

resource "aws_iam_role_policy_attachment" "task_attachement" {
  role       = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.ecs_exec_policy.arn
}

# ECSタスク実行ロール
resource "aws_iam_role" "execution_role" {
  name               = "nginx-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_doc.json
}

resource "aws_iam_role_policy_attachment" "execution_attachement" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# デフォルトセキュリティグループ(デフォルトルール削除のため)
resource "aws_default_security_group" "dfsg" {
  vpc_id = module.network.vpc_id
}

# ECSサービス用セキュリティグループ
resource "aws_security_group" "sg" {
  name        = "ecs-sg"
  description = "ecs-sg"
  vpc_id      = module.network.vpc_id

  tags = {
    Name = "nginx-sg"
  }
}

resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg.id
}

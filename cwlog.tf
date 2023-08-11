# ロググループ
resource "aws_cloudwatch_log_group" "log_nginx" {
  name = "/ecs/nginx"
}

resource "aws_cloudwatch_log_group" "log_connect_frontend" {
  name = "/ecs/svccon-frontend"
}

resource "aws_cloudwatch_log_group" "log_connect_backend" {
  name = "/ecs/svccon-backend"
}

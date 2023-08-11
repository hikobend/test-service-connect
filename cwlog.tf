# ロググループ
resource "aws_cloudwatch_log_group" "log_nginx" {
  name = "/ecs/nginx"
}

resource "aws_cloudwatch_log_group" "log_connect_client" {
  name = "/ecs/svccon-client"
}

resource "aws_cloudwatch_log_group" "log_connect_server" {
  name = "/ecs/svccon-server"
}

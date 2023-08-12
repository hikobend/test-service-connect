# タスク定義
resource "aws_ecs_task_definition" "client-task" {
  family                   = "nginx-task"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.task_role.arn
  execution_role_arn       = aws_iam_role.execution_role.arn
  requires_compatibilities = ["FARGATE"]
  container_definitions    = <<-EOS
  [
    {
      "name": "nginx-container",
      "image": "nginx:latest",
      "essential": true,
      "memory": 128,
      "portMappings": [
        {
          "name": "webclient",
          "protocol": "tcp",
          "containerPort": 80,
          "appProtocol": "http"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/nginx",
          "awslogs-region": "ap-northeast-1",
          "awslogs-stream-prefix": "nginx"
        }
      }
    }
  ]
  EOS
}

# タスク定義
resource "aws_ecs_task_definition" "server-task" {
  family                   = "nginx-task"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.task_role.arn
  execution_role_arn       = aws_iam_role.execution_role.arn
  requires_compatibilities = ["FARGATE"]
  container_definitions    = <<-EOS
  [
    {
      "name": "nginx-container",
      "image": "nginx:latest",
      "essential": true,
      "memory": 128,
      "portMappings": [
        {
          "name": "webserver",
          "protocol": "tcp",
          "containerPort": 80,
          "appProtocol": "http"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/nginx",
          "awslogs-region": "ap-northeast-1",
          "awslogs-stream-prefix": "nginx"
        }
      }
    }
  ]
  EOS
}

# クラスター
resource "aws_ecs_cluster" "cluster" {
  name = "test-cluster"
}

# 名前空間
resource "aws_service_discovery_http_namespace" "namespace" {
  name = "test-namespace"
}


# サービス(クライアント側)
resource "aws_ecs_service" "client" {
  name                   = "nginx-client"
  cluster                = aws_ecs_cluster.cluster.arn
  task_definition        = aws_ecs_task_definition.client-task.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  platform_version       = "1.4.0"
  enable_execute_command = true

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.sg.id]
    subnets          = [module.network.public_subnets[0], module.network.public_subnets[1]]
  }

  service_connect_configuration {
    enabled = true

    log_configuration {
      log_driver = "awslogs"
      options = {
        awslogs-group         = "/ecs/svccon-client"
        awslogs-region        = "ap-northeast-1"
        awslogs-stream-prefix = "svccon-client"
      }
    }

    namespace = aws_service_discovery_http_namespace.namespace.arn
  }
}

# サービス(サーバー側)
resource "aws_ecs_service" "server" {
  name                   = "nginx-server"
  cluster                = aws_ecs_cluster.cluster.arn
  task_definition        = aws_ecs_task_definition.server-task.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  platform_version       = "1.4.0"
  enable_execute_command = true

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.sg.id]
    subnets          = [module.network.public_subnets[0], module.network.public_subnets[1]]
  }

  service_connect_configuration {
    enabled = true

    log_configuration {
      log_driver = "awslogs"
      options = {
        awslogs-group         = "/ecs/svccon-server"
        awslogs-region        = "ap-northeast-1"
        awslogs-stream-prefix = "svccon-server"
      }
    }

    namespace = aws_service_discovery_http_namespace.namespace.arn

    service {
      client_alias {
        port = 80
      }
      port_name = "webserver"
    }
  }
}

resource "aws_ecs_service" "nginx_service" {
  name            = "nginx-fargate-service"
  launch_type     = "FARGATE"
  desired_count   = 2

  cluster         = data.aws_ecs_cluster.existing.arn
  task_definition = aws_ecs_task_definition.nginx_task.arn

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.nginx_tg.arn  # You need to create this target group
    container_name   = "nginx-app"  # Must match the container name in your task definition
    container_port   = 80           # Must match the container port in your task definition
  }

  network_configuration {
    subnets          = data.aws_subnets.public.ids
    security_groups  = [aws_security_group.ecs_sg.id]  # You need to create this security group
    assign_public_ip = true  # Required for Fargate in public subnets
  }

  depends_on = [aws_lb_listener.nginx_listener]  # You'll need this listener too
}
resource "aws_cloudwatch_log_group" "nginx_logs" {
  name              = "/ecs/nginx-fargate-service"
  retention_in_days = 7
}
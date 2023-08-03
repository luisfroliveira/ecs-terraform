# Cria um cluster ECS com o nome especificado pela variável local "name"
resource "aws_ecs_cluster" "ecs-name" {
  name = local.name
}

# Associa o provedor de capacidade ao cluster ECS
resource "aws_ecs_cluster_capacity_providers" "ecs-cp" {
  cluster_name = aws_ecs_cluster.ecs-name.name

  capacity_providers = [aws_ecs_capacity_provider.ecs-cp.name]

  # Define a estratégia de provedor de capacidade padrão para o cluster
  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.ecs-cp.name
  }
}

# Cria um provedor de capacidade ECS que usa o grupo de escalonamento automático especificado
resource "aws_ecs_capacity_provider" "ecs-cp" {
  name = "capacity-provider-test"
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs-auto.arn
    managed_termination_protection = "ENABLED"

    # Habilita o gerenciamento de escala para o grupo de escalonamento automático
    managed_scaling {
      status          = "ENABLED"
      target_capacity = 85
    }
  }
}

# Cria uma definição de tarefa ECS com uma única definição de contêiner
resource "aws_ecs_task_definition" "task" {
  family = "service"
  container_definitions = jsonencode([
    {
      name      = "ecs-terraform"
      image     = "httpd:latest"
      cpu: 300,
      memory: 350,
      essential: true,
      portMappings: [
        {
          containerPort = 80
          hostPort      = 8080
          protocol      = "tcp"
        }
      ],  
    }])
}

# Cria um serviço ECS no cluster especificado usando a definição de tarefa especificada
resource "aws_ecs_service" "service" {
  name            = "web-service"
  cluster         = aws_ecs_cluster.ecs-name.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  
  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.lb_target_group.arn
    container_name   = "ecs-terraform"
    container_port   = 80
  }
  
# Ignora as alterações no atributo desired_count durante a atualização do recurso
  lifecycle {
    ignore_changes = [desired_count]
  }
  
  launch_type = "EC2"
  depends_on  = [aws_lb_listener.web-listener]
}

# Cria um AWS Application Load Balancer (ALB) chamado "ecs-lb"
resource "aws_lb" "ecs-lb" {
  name               = "ecs-lb"
  internal           = false # O ALB não é interno
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ec2-sg.id] # Associa o ALB a um grupo de segurança
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id] # Associa o ALB a duas sub-redes públicas
}

# Cria um grupo de destino chamado "ecs-target-group"
resource "aws_lb_target_group" "lb_target_group" {
  name        = "ecs-target-group"
  port        = "80"
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.ecs-vpc.id

  # Configura a verificação de integridade para o grupo de destino
  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 60
    interval            = 300
    matcher             = "200,301,302"
  }
}

# Cria um ouvinte HTTP na porta 80 para o ALB
resource "aws_lb_listener" "web-listener" {
  load_balancer_arn = aws_lb.ecs-lb.arn
  port              = "80"
  protocol          = "HTTP"

  # Define a ação padrão para o ouvinte encaminhar o tráfego para o grupo de destino
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}

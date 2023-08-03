# Cria um grupo de escalonamento automático com o nome "auto-scaling"
resource "aws_autoscaling_group" "ecs-auto" {
  name                      = "auto-scaling"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 1
  launch_configuration      = aws_launch_configuration.as_conf.name
  vpc_zone_identifier       = [aws_subnet.public1.id, aws_subnet.public2.id]
  
  # Protege as instâncias do grupo de escalonamento automático contra a redução de escala
  protect_from_scale_in     = true

  # Define o tempo limite para exclusão do grupo de escalonamento automático
  timeouts {
    delete = "15m"
  }
} 

# Cria uma configuração de lançamento com o prefixo de nome "ecs-launch"
resource "aws_launch_configuration" "as_conf" {
  name_prefix                 = "ecs-launch"
  
  # Usa a AMI otimizada para ECS especificada pelo parâmetro SSM
  image_id                    = jsondecode(data.aws_ssm_parameter.ecs_optimized_ami.value)["image_id"]
  
  instance_type               = "t2.micro"
  
  # Associa o perfil da instância IAM especificado às instâncias lançadas
  iam_instance_profile        = aws_iam_instance_profile.ecs_service_role.name
  
  # Define os dados do usuário para as instâncias lançadas
  user_data                   = base64encode(local.user_data)
  
  # Associa o grupo de segurança especificado às instâncias lançadas
  security_groups             = [aws_security_group.ec2-sg.id]
  
  associate_public_ip_address = true

  # Define a diretiva do ciclo de vida para criar uma nova configuração de lançamento antes de destruir a antiga
  lifecycle {
    create_before_destroy = true
  }
}

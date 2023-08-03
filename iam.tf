# Cria uma função IAM com o nome "ecs-instance-role-terraform" e um caminho "/"
resource "aws_iam_role" "ecs-instance-role" {
  name = "ecs-instance-role-terraform"
  path = "/"

  # Define a política de confiança da função para permitir que o serviço EC2 assuma a função
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

# Anexa a política gerenciada "AmazonEC2ContainerServiceforEC2Role" à função IAM
resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
  role       = aws_iam_role.ecs-instance-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# Anexa a política gerenciada "AmazonEC2RoleforSSM" à função IAM
resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment-ssm" {
  role       = aws_iam_role.ecs-instance-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

# Anexa a política gerenciada "AmazonEC2ContainerServiceRole" à função IAM
resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment-ecs" {
  role       = aws_iam_role.ecs-instance-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

# Cria um perfil de instância IAM associado à função IAM
resource "aws_iam_instance_profile" "ecs_service_role" {
  role = aws_iam_role.ecs-instance-role.name
}

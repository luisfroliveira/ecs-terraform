# Cria um grupo de segurança que permite todo o tráfego de entrada e saída
resource "aws_security_group" "ec2-sg" {
  name        = "allow-all-ec2"
  description = "allow all"
  vpc_id      = aws_vpc.ecs-vpc.id
  
  # Permite todo o tráfego de entrada
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Permite todo o tráfego de saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
  }
}

# Cria uma VPC com o bloco CIDR especificado
resource "aws_vpc" "ecs-vpc" {
  cidr_block = "10.0.0.0/16"
}

# Cria uma sub-rede pública na zona de disponibilidade "us-east-1a"
resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.ecs-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  
  # Habilita o mapeamento automático de endereços IP públicos para instâncias lançadas na sub-rede
  map_public_ip_on_launch = true
}

# Cria uma sub-rede pública na zona de disponibilidade "us-east-1b"
resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.ecs-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  
  # Habilita o mapeamento automático de endereços IP públicos para instâncias lançadas na sub-rede
  map_public_ip_on_launch = true
}

# Cria um gateway da Internet e o associa à VPC especificada
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ecs-vpc.id
}

# Cria uma tabela de rotas para a VPC especificada com uma rota padrão para o gateway da Internet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.ecs-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Associa a tabela de rotas à sub-rede pública1
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

# Associa a tabela de rotas à sub-rede pública2
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

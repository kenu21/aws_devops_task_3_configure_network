# Add your code here:

# 1. Create a subnet
resource "aws_subnet" "grafana_subnet" {
  vpc_id     = var.vpc_id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "grafana"
  }
}

# 2. Create an Internet Gateway and attach it to the vpc
resource "aws_internet_gateway" "grafana_igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "mate-aws-grafana-lab"
  }
}

# 3. Configure routing for the Internet Gateway
resource "aws_route_table" "grafana_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.grafana_igw.id
  }

  tags = {
    Name = "mate-aws-grafana-lab"
  }
}

resource "aws_route_table_association" "grafana_rta" {
  subnet_id      = aws_subnet.grafana_subnet.id
  route_table_id = aws_route_table.grafana_route_table.id
}

# 4. Create a Security Group and inbound rules
resource "aws_security_group" "grafana_sg" {
  name   = "mate-aws-grafana-lab"
  vpc_id = var.vpc_id

  tags = {
    Name = "mate-aws-grafana-lab"
  }
}

# 5. Uncommend (and update the value of security_group_id if required) outbound rule - it required
# to allow outbound traffic from your virtual machine:
resource "aws_vpc_security_group_egress_rule" "allow_all_eggress" {
  security_group_id = aws_security_group.grafana_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}

resource "aws_vpc_security_group_ingress_rule" "grafana_3000" {
  security_group_id = aws_security_group.grafana_sg.id
  ip_protocol       = "tcp"
  from_port         = 3000
  to_port           = 3000
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.grafana_sg.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "1.2.3.4/32"
}

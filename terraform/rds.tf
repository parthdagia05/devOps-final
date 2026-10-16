resource "aws_db_subnet_group" "rds" {
  name       = "orders-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "orders-db-subnet-group"
  }
}

resource "aws_security_group" "rds" {
  name        = "orders-rds-sg"
  description = "Allow inbound PostgreSQL traffic from EKS worker nodes"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "PostgreSQL access from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "orders-rds-sg"
  }
}

resource "aws_db_instance" "postgres" {
  identifier             = "orders-db"
  allocated_storage      = 20
  max_allocated_storage  = 50
  engine                 = "postgres"
  engine_version         = "17"
  instance_class         = "db.t4g.micro"
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = {
    Name = "orders-postgres-rds"
  }
}

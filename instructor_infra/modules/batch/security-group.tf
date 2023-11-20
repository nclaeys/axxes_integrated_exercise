resource "aws_security_group" "batch_instance" {
  name        = "batch-instance-${var.env_name}"
  description = "controls access to the instance"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 0
    to_port         = 0
    cidr_blocks     = var.allowed_cidrs
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
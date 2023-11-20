locals {
  batch_cluster_name="${var.env_name}-batch-cluster"
}

data "aws_iam_policy_document" "batch_instance_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "batch_instance" {
  name               = "batch-instance-${var.env_name}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.batch_instance_policy.json
}

resource "aws_iam_instance_profile" "batch_instance" {
  name = "batch-instance-${var.env_name}"
  role = aws_iam_role.batch_instance.name
}

resource "aws_iam_role_policy_attachment" "batch_instance" {
  role       = aws_iam_role.batch_instance.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

data "aws_iam_policy_document" "batch_service_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["batch.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "batch_service" {
  name               = "batch-service-${var.env_name}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.batch_service_policy.json
}

resource "aws_iam_role_policy_attachment" "batch_service" {
  role       = aws_iam_role.batch_service.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

data "aws_iam_policy_document" "batch_spot_fleet_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["spotfleet.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "batch_spot_fleet" {
  name               = "batch-spot-fleet-${var.env_name}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.batch_spot_fleet_policy.json
}

resource "aws_iam_role_policy_attachment" "batch_spot_fleet" {
  role       = aws_iam_role.batch_spot_fleet.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
}

resource "aws_launch_template" "default" {
  name     = "batch-${var.env_name}"
  image_id = "ami-0fc76c7f5cfa96e89"
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 500
      volume_type = "gp3"
    }
  }
}

resource "aws_batch_compute_environment" "default" {
  compute_environment_name = local.batch_cluster_name
  compute_resources {
    instance_role = aws_iam_instance_profile.batch_instance.arn
    instance_type = [
      "optimal"
    ]

    launch_template {
      launch_template_id = aws_launch_template.default.id
    }

    max_vcpus     = 10
    min_vcpus     = 0
    desired_vcpus = 5
    security_group_ids = [
      aws_security_group.batch_instance.id
    ]
    subnets             = var.private_subnet_ids
    type                = "EC2"
#    allocation_strategy = "SPOT_CAPACITY_OPTIMIZED"
    bid_percentage      = 100
    spot_iam_fleet_role = aws_iam_role.batch_spot_fleet.arn

    tags = {
      Name = "batch-${var.env_name}"
    }
  }
  service_role = aws_iam_role.batch_service.arn
  type         = "MANAGED"
  depends_on   = [aws_iam_role_policy_attachment.batch_service]

  lifecycle {
    ignore_changes = [
      compute_resources.0.min_vcpus,
      compute_resources.0.desired_vcpus,
    ]
  }
}

resource "aws_batch_job_queue" "default" {
  name                 = "${var.env_name}-job-queue"
  state                = "ENABLED"
  priority             = 100
  compute_environments = [aws_batch_compute_environment.default.arn]
  tags = {
    "environment": var.env_name
  }
}

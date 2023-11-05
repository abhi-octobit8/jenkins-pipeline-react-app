provider "aws" {
  region = "us-west-2"  # Specify your desired AWS region
}

resource "aws_eks_cluster" "example_cluster" {
  name     = "my-eks-cluster"
  role_arn = aws_iam_role.example_eks_role.arn

  vpc_config {
    subnet_ids = aws_subnet.example_subnet[*].id
  }

  depends_on = [
    aws_eks_fargate_profile.example_fargate_profile,
  ]
}

resource "aws_eks_fargate_profile" "example_fargate_profile" {
  cluster_name = aws_eks_cluster.example_cluster.name
  fargate_profile_name = "example-fargate-profile"

  pod_execution_role_arn = aws_iam_role.example_fargate_role.arn
  subnet_ids            = aws_subnet.example_subnet[*].id
}

resource "aws_iam_role" "example_eks_role" {
  name = "example-eks-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "example_fargate_role" {
  name = "example-fargate-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks-fargate-pods.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_subnet" "example_subnet" {
  count = 2  # Adjust the count based on the number of subnets you want
  vpc_id = aws_vpc.example_vpc.id

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block       = "10.0.${count.index}.0/24"
}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
}

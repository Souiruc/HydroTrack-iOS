# HydroTrack AWS Infrastructure
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure AWS Provider
provider "aws" {
  region = "us-east-1"
}

# DynamoDB Table for Users
resource "aws_dynamodb_table" "users" {
  name           = "hydrotrack-users"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "user_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  tags = {
    Name        = "HydroTrack Users"
    Environment = "development"
  }
}

# DynamoDB Table for Water Logs
resource "aws_dynamodb_table" "water_logs" {
  name           = "hydrotrack-water-logs"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "user_id"
  range_key      = "timestamp"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  tags = {
    Name        = "HydroTrack Water Logs"
    Environment = "development"
  }
}

# DynamoDB Table for Partnerships
resource "aws_dynamodb_table" "partnerships" {
  name           = "hydrotrack-partnerships"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "partnership_id"

  attribute {
    name = "partnership_id"
    type = "S"
  }

  tags = {
    Name        = "HydroTrack Partnerships"
    Environment = "development"
  }
}

# IAM Role for Lambda Functions
resource "aws_iam_role" "lambda_role" {
  name = "hydrotrack-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Lambda to access DynamoDB
resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name = "hydrotrack-lambda-dynamodb-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ]
        Resource = [
          aws_dynamodb_table.users.arn,
          aws_dynamodb_table.water_logs.arn,
          aws_dynamodb_table.partnerships.arn
        ]
      }
    ]
  })
}

# Attach basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

# API Gateway
resource "aws_api_gateway_rest_api" "hydrotrack_api" {
  name        = "hydrotrack-api"
  description = "HydroTrack Water Tracking API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Output important values
output "dynamodb_tables" {
  value = {
    users_table       = aws_dynamodb_table.users.name
    water_logs_table  = aws_dynamodb_table.water_logs.name
    partnerships_table = aws_dynamodb_table.partnerships.name
  }
}

output "api_gateway_url" {
  value = aws_api_gateway_rest_api.hydrotrack_api.execution_arn
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}
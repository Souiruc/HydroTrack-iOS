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

# Get current AWS region
data "aws_region" "current" {}

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

# Lambda Function for Create User
data "archive_file" "create_user_zip" {
  type        = "zip"
  source_dir  = "../lambda/create-user"
  output_path = "create_user.zip"
}

resource "aws_lambda_function" "create_user" {
  filename         = "create_user.zip"
  function_name    = "hydrotrack-create-user"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  source_code_hash = data.archive_file.create_user_zip.output_base64sha256

  tags = {
    Name        = "HydroTrack Create User"
    Environment = "development"
  }
}

# API Gateway
resource "aws_api_gateway_rest_api" "hydrotrack_api" {
  name        = "hydrotrack-api"
  description = "HydroTrack Water Tracking API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# API Gateway Resource for /users
resource "aws_api_gateway_resource" "users" {
  rest_api_id = aws_api_gateway_rest_api.hydrotrack_api.id
  parent_id   = aws_api_gateway_rest_api.hydrotrack_api.root_resource_id
  path_part   = "users"
}

# API Gateway Method POST /users
resource "aws_api_gateway_method" "create_user_post" {
  rest_api_id   = aws_api_gateway_rest_api.hydrotrack_api.id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = "POST"
  authorization = "NONE"
}

# API Gateway Integration
resource "aws_api_gateway_integration" "create_user_integration" {
  rest_api_id = aws_api_gateway_rest_api.hydrotrack_api.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.create_user_post.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.create_user.invoke_arn
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "api_gateway_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.hydrotrack_api.execution_arn}/*/*"
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "hydrotrack_deployment" {
  depends_on = [
    aws_api_gateway_method.create_user_post,
    aws_api_gateway_integration.create_user_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.hydrotrack_api.id
}

# API Gateway Stage`
resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.hydrotrack_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.hydrotrack_api.id
  stage_name    = "prod"
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
  value = "https://${aws_api_gateway_rest_api.hydrotrack_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/prod"
}

output "lambda_function_name" {
  value = aws_lambda_function.create_user.function_name
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}
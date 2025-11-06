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

# Cognito User Pool for Authentication
resource "aws_cognito_user_pool" "hydrotrack_users" {
  name = "hydrotrack-users"

  # Password policy
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
  }

  # User attributes
  schema {
    attribute_data_type = "String"
    name               = "email"
    required           = true
    mutable            = true
  }

  # Auto-verify email
  auto_verified_attributes = ["email"]

  tags = {
    Name        = "HydroTrack User Pool"
    Environment = "development"
  }
}

# Cognito User Pool Client
resource "aws_cognito_user_pool_client" "hydrotrack_client" {
  name         = "hydrotrack-client"
  user_pool_id = aws_cognito_user_pool.hydrotrack_users.id

  # Authentication flows
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  # Token validity
  access_token_validity  = 24  # 24 hours
  refresh_token_validity = 30  # 30 days
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

# Lambda Function for Get User
data "archive_file" "get_user_zip" {
  type        = "zip"
  source_dir  = "../lambda/get-user"
  output_path = "get_user.zip"
}

resource "aws_lambda_function" "get_user" {
  filename         = "get_user.zip"
  function_name    = "hydrotrack-get-user"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  source_code_hash = data.archive_file.get_user_zip.output_base64sha256

  tags = {
    Name        = "HydroTrack Get User"
    Environment = "development"
  }
}

# Lambda Function for Log Water
data "archive_file" "log_water_zip" {
  type        = "zip"
  source_dir  = "../lambda/log-water"
  output_path = "log_water.zip"
}

resource "aws_lambda_function" "log_water" {
  filename         = "log_water.zip"
  function_name    = "hydrotrack-log-water"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  source_code_hash = data.archive_file.log_water_zip.output_base64sha256

  tags = {
    Name        = "HydroTrack Log Water"
    Environment = "development"
  }
}

# Lambda Function for Get Water Logs
data "archive_file" "get_water_logs_zip" {
  type        = "zip"
  source_dir  = "../lambda/get-water-logs"
  output_path = "get_water_logs.zip"
}

resource "aws_lambda_function" "get_water_logs" {
  filename         = "get_water_logs.zip"
  function_name    = "hydrotrack-get-water-logs"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  source_code_hash = data.archive_file.get_water_logs_zip.output_base64sha256

  tags = {
    Name        = "HydroTrack Get Water Logs"
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

# API Gateway Resource for /users/{id}
resource "aws_api_gateway_resource" "user_id" {
  rest_api_id = aws_api_gateway_rest_api.hydrotrack_api.id
  parent_id   = aws_api_gateway_resource.users.id
  path_part   = "{id}"
}

# API Gateway Resource for /water-logs
resource "aws_api_gateway_resource" "water_logs" {
  rest_api_id = aws_api_gateway_rest_api.hydrotrack_api.id
  parent_id   = aws_api_gateway_rest_api.hydrotrack_api.root_resource_id
  path_part   = "water-logs"
}

# API Gateway Method POST /users
resource "aws_api_gateway_method" "create_user_post" {
  rest_api_id   = aws_api_gateway_rest_api.hydrotrack_api.id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = "POST"
  authorization = "NONE"
}

# API Gateway Method GET /users/{id}
resource "aws_api_gateway_method" "get_user_get" {
  rest_api_id   = aws_api_gateway_rest_api.hydrotrack_api.id
  resource_id   = aws_api_gateway_resource.user_id.id
  http_method   = "GET"
  authorization = "NONE"
}

# API Gateway Method POST /water-logs (Protected)
resource "aws_api_gateway_method" "log_water_post" {
  rest_api_id   = aws_api_gateway_rest_api.hydrotrack_api.id
  resource_id   = aws_api_gateway_resource.water_logs.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

# API Gateway Method GET /water-logs (Protected)
resource "aws_api_gateway_method" "get_water_logs_get" {
  rest_api_id   = aws_api_gateway_rest_api.hydrotrack_api.id
  resource_id   = aws_api_gateway_resource.water_logs.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

# API Gateway Integration for Create User
resource "aws_api_gateway_integration" "create_user_integration" {
  rest_api_id = aws_api_gateway_rest_api.hydrotrack_api.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.create_user_post.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.create_user.invoke_arn
}

# API Gateway Integration for Get User
resource "aws_api_gateway_integration" "get_user_integration" {
  rest_api_id = aws_api_gateway_rest_api.hydrotrack_api.id
  resource_id = aws_api_gateway_resource.user_id.id
  http_method = aws_api_gateway_method.get_user_get.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.get_user.invoke_arn
}

# API Gateway Integration for Log Water
resource "aws_api_gateway_integration" "log_water_integration" {
  rest_api_id = aws_api_gateway_rest_api.hydrotrack_api.id
  resource_id = aws_api_gateway_resource.water_logs.id
  http_method = aws_api_gateway_method.log_water_post.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.log_water.invoke_arn
}

# API Gateway Integration for Get Water Logs
resource "aws_api_gateway_integration" "get_water_logs_integration" {
  rest_api_id = aws_api_gateway_rest_api.hydrotrack_api.id
  resource_id = aws_api_gateway_resource.water_logs.id
  http_method = aws_api_gateway_method.get_water_logs_get.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.get_water_logs.invoke_arn
}

# API Gateway Authorizer
resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name          = "hydrotrack-cognito-authorizer"
  rest_api_id   = aws_api_gateway_rest_api.hydrotrack_api.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [aws_cognito_user_pool.hydrotrack_users.arn]
}

# Lambda Permission for API Gateway - Create User
resource "aws_lambda_permission" "api_gateway_create_user" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.hydrotrack_api.execution_arn}/*/*"
}

# Lambda Permission for API Gateway - Get User
resource "aws_lambda_permission" "api_gateway_get_user" {
  statement_id  = "AllowExecutionFromAPIGatewayGetUser"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.hydrotrack_api.execution_arn}/*/*"
}

# Lambda Permission for API Gateway - Log Water
resource "aws_lambda_permission" "api_gateway_log_water" {
  statement_id  = "AllowExecutionFromAPIGatewayLogWater"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.log_water.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.hydrotrack_api.execution_arn}/*/*"
}

# Lambda Permission for API Gateway - Get Water Logs
resource "aws_lambda_permission" "api_gateway_get_water_logs" {
  statement_id  = "AllowExecutionFromAPIGatewayGetWaterLogs"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_water_logs.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.hydrotrack_api.execution_arn}/*/*"
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "hydrotrack_deployment" {
  depends_on = [
    aws_api_gateway_method.create_user_post,
    aws_api_gateway_integration.create_user_integration,
    aws_api_gateway_method.get_user_get,
    aws_api_gateway_integration.get_user_integration,
    aws_api_gateway_method.log_water_post,
    aws_api_gateway_integration.log_water_integration,
    aws_api_gateway_method.get_water_logs_get,
    aws_api_gateway_integration.get_water_logs_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.hydrotrack_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.users.id,
      aws_api_gateway_resource.user_id.id,
      aws_api_gateway_resource.water_logs.id,
      aws_api_gateway_method.create_user_post.id,
      aws_api_gateway_method.get_user_get.id,
      aws_api_gateway_method.log_water_post.id,
      aws_api_gateway_method.get_water_logs_get.id,
      aws_api_gateway_integration.create_user_integration.id,
      aws_api_gateway_integration.get_user_integration.id,
      aws_api_gateway_integration.log_water_integration.id,
      aws_api_gateway_integration.get_water_logs_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
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

output "lambda_functions" {
  value = {
    create_user      = aws_lambda_function.create_user.function_name
    get_user         = aws_lambda_function.get_user.function_name
    log_water        = aws_lambda_function.log_water.function_name
    get_water_logs   = aws_lambda_function.get_water_logs.function_name
  }
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.hydrotrack_users.id
}

output "cognito_client_id" {
  value = aws_cognito_user_pool_client.hydrotrack_client.id
}
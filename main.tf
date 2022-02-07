terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.48.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }

  required_version = "~> 1.0"
}


terraform {
  cloud {
    organization = "${var.terraform_cloud_org}"

    workspaces {
      name = "${var.terraform_cloud_workspace}"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "web-app-bucket-1"

  acl           = "private"
  force_destroy = true
}

//second 

data "archive_file" "lambda_web_app" {
  type = "zip"

  source_dir  = "web-app"
  output_path = "web-app.zip"
}

resource "aws_s3_bucket_object" "lambda_web_app" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "web-app.zip"
  source = data.archive_file.lambda_web_app.output_path

  etag = filemd5(data.archive_file.lambda_web_app.output_path)
}

//third

resource "aws_lambda_function" "web_app" {
  function_name = "web_app"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_bucket_object.lambda_web_app.key

  runtime = "python3.6"
  handler = "app.handler"

  source_code_hash = data.archive_file.lambda_web_app.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

//four and api starts here

resource "aws_apigatewayv2_api" "lambda" {
  name          = "serverless_lambda_gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  name        = "serverless_lambda_stage"
  auto_deploy = true

}

resource "aws_apigatewayv2_integration" "web_app" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.web_app.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "web_app_get" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /api"
  target    = "integrations/${aws_apigatewayv2_integration.web_app.id}"
}

resource "aws_apigatewayv2_route" "web_app_post" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "POST /api"
  target    = "integrations/${aws_apigatewayv2_integration.web_app.id}"
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

  retention_in_days = 30
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.web_app.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}



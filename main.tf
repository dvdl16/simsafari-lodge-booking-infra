terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  profile = "jabulani"
}


# Roles
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# Policies
resource "aws_iam_policy" "iam_policy_for_lambda" {
  name        = "aws_iam_policy_for_terraform_aws_lambda_role"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:*:*:*",
        "Effect" : "Allow"
      }
    ]
  })
}

resource "aws_iam_policy" "iam_dynamodb_privilege_policy" {
  name        = "aws_iam_dynamodb_privilege_policy"
  path        = "/"
  description = "AWS IAM Policy for GetItem and PutItem privileges on DynamoDB "
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "dynamodb:PutItem",
          "dynamodb:GetItem"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

resource "aws_iam_role_policy_attachment" "attach_iam_dynamodb_privilege_policy_to_iam_role" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.iam_dynamodb_privilege_policy.arn
}

# Data
data "archive_file" "zipped_go_code" {
  type        = "zip"
  source_dir  = "${path.module}/api/"
  output_path = "${path.module}/api/main.zip"
}

# Lambda Function
resource "aws_lambda_function" "terraform_lambda_func" {
  filename         = "${path.module}/api/main.zip"
  source_code_hash = filebase64sha256("${path.module}/api/main.zip")
  function_name    = "SimSafari_Lodge_Booking_API"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "main"
  runtime          = "go1.x"
  depends_on       = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}

# Database
resource "aws_dynamodb_table" "tf_bookings_table" {
  name           = "tf-bookings-table"
  billing_mode   = "PROVISIONED"
  read_capacity  = "5"
  write_capacity = "5"
  attribute {
    name = "bookingId"
    type = "S"
  }
  hash_key = "bookingId"
}
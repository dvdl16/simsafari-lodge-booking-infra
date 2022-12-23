
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
  description = "AWS IAM Policy for PutItem, GetItem, Scan and UpdateItem privileges on DynamoDB "
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:UpdateItem"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_iam_dynamodb_privilege_policy_to_iam_role" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.iam_dynamodb_privilege_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

# Data
data "archive_file" "zipped_go_code" {
  type        = "zip"
  source_dir  = "${path.module}/../api/"
  output_path = "${path.module}/../api/main.zip"
}

# Lambda Function
resource "aws_lambda_function" "terraform_lambda_func" {
  filename         = "${path.module}/../api/main.zip"
  source_code_hash = filebase64sha256("${path.module}/../api/main.zip")
  function_name    = "SimSafari_Lodge_Booking_API"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "main"
  runtime          = "go1.x"
  depends_on       = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}

resource "aws_lambda_function_url" "terraform_lambda_func_url_latest" {
  function_name      = aws_lambda_function.terraform_lambda_func.function_name
  authorization_type = "NONE"
}


resource "aws_lambda_permission" "tf_bookings_store_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.terraform_lambda_func.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${aws_api_gateway_rest_api.tf_bookings_store.id}/*/${aws_api_gateway_method.bookings_method.http_method}${aws_api_gateway_resource.bookings.path}"
}


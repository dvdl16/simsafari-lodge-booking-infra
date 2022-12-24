
# API Gateway
resource "aws_api_gateway_rest_api" "tf_bookings_store" {
  name = "tf_bookings_store"
}



resource "aws_api_gateway_resource" "bookings" {
  parent_id   = aws_api_gateway_rest_api.tf_bookings_store.root_resource_id
  path_part   = "bookings"
  rest_api_id = aws_api_gateway_rest_api.tf_bookings_store.id
}

resource "aws_api_gateway_method" "bookings_method" {
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_auth.id
  http_method   = "ANY"
  resource_id   = aws_api_gateway_resource.bookings.id
  rest_api_id   = aws_api_gateway_rest_api.tf_bookings_store.id
}

resource "aws_api_gateway_integration" "bookings_lambda_integration" {
  http_method             = aws_api_gateway_method.bookings_method.http_method
  resource_id             = aws_api_gateway_resource.bookings.id
  rest_api_id             = aws_api_gateway_rest_api.tf_bookings_store.id
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.terraform_lambda_func.invoke_arn
  content_handling        = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_authorizer" "cognito_auth" {
  name                   = "cognito_auth"
  type                   = "COGNITO_USER_POOLS"
  rest_api_id            = aws_api_gateway_rest_api.tf_bookings_store.id
  authorizer_uri         = aws_lambda_function.terraform_lambda_func.invoke_arn
  authorizer_credentials = aws_iam_role.invocation_role.arn
  provider_arns          = ["arn:aws:cognito-idp:${var.aws_region}:${var.aws_account_id}:userpool/${aws_cognito_user_pool.lambda_user_pool.id}"]
}

resource "aws_iam_role" "invocation_role" {
  name = "api_gateway_auth_invocation"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "invocation_policy" {
  name = "default"
  role = aws_iam_role.invocation_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": "${aws_lambda_function.terraform_lambda_func.arn}"
    }
  ]
}
EOF
}

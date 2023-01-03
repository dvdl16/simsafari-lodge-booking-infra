
# API Gateway
resource "aws_api_gateway_rest_api" "tf_bookings_store" {
  name = "tf_bookings_store"
}

resource "aws_api_gateway_resource" "bookings" {
  parent_id   = aws_api_gateway_rest_api.tf_bookings_store.root_resource_id
  path_part   = "bookings"
  rest_api_id = aws_api_gateway_rest_api.tf_bookings_store.id
}

resource "aws_api_gateway_resource" "payments" {
  parent_id   = aws_api_gateway_rest_api.tf_bookings_store.root_resource_id
  path_part   = "payments"
  rest_api_id = aws_api_gateway_rest_api.tf_bookings_store.id
}

# CORS for 'bookings' APIGateway Resource
resource "aws_api_gateway_method" "options_method" {
  rest_api_id   = aws_api_gateway_rest_api.tf_bookings_store.id
  resource_id   = aws_api_gateway_resource.bookings.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.tf_bookings_store.id
  resource_id = aws_api_gateway_resource.bookings.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Status200InBody"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  depends_on = [aws_api_gateway_method.options_method]
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id = aws_api_gateway_rest_api.tf_bookings_store.id
  resource_id = aws_api_gateway_resource.bookings.id
  http_method = aws_api_gateway_method.options_method.http_method
  type        = "MOCK"
  depends_on  = [aws_api_gateway_method.options_method]
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates = {
    "application/json" = <<EOF
#set($inputRoot = $input.path('$'))
{
  "statusCode" : 200
}
EOF
  }
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.tf_bookings_store.id
  resource_id = aws_api_gateway_resource.bookings.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = aws_api_gateway_method_response.options_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,Access-Control-Allow-Origin'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT,DELETE'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [
    aws_api_gateway_method.options_method,
    aws_api_gateway_method_response.options_200,
    aws_api_gateway_integration.options_integration
  ]
}

# CORS for 'payments' APIGateway Resource
resource "aws_api_gateway_method" "options_payments_method" {
  rest_api_id   = aws_api_gateway_rest_api.tf_bookings_store.id
  resource_id   = aws_api_gateway_resource.payments.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "options_payment_200" {
  rest_api_id = aws_api_gateway_rest_api.tf_bookings_store.id
  resource_id = aws_api_gateway_resource.payments.id
  http_method = aws_api_gateway_method.options_payments_method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Status200InBody"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
  depends_on = [aws_api_gateway_method.options_payments_method]
}

resource "aws_api_gateway_integration" "options_payment_integration" {
  rest_api_id = aws_api_gateway_rest_api.tf_bookings_store.id
  resource_id = aws_api_gateway_resource.payments.id
  http_method = aws_api_gateway_method.options_payments_method.http_method
  type        = "MOCK"
  depends_on  = [aws_api_gateway_method.options_payments_method]
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates = {
    "application/json" = <<EOF
#set($inputRoot = $input.path('$'))
{
  "statusCode" : 200
}
EOF
  }
}

resource "aws_api_gateway_integration_response" "options_payments_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.tf_bookings_store.id
  resource_id = aws_api_gateway_resource.payments.id
  http_method = aws_api_gateway_method.options_payments_method.http_method
  status_code = aws_api_gateway_method_response.options_payment_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,Access-Control-Allow-Origin'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT,DELETE'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [
    aws_api_gateway_method.options_payments_method,
    aws_api_gateway_method_response.options_payment_200,
    aws_api_gateway_integration.options_payment_integration
  ]
}

# Terraform APIGateway Resources for 'bookings'
resource "aws_api_gateway_method" "bookings_method" {
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_auth.id
  http_method   = "ANY"
  resource_id   = aws_api_gateway_resource.bookings.id
  rest_api_id   = aws_api_gateway_rest_api.tf_bookings_store.id
}

resource "aws_api_gateway_method_response" "bookings_method_response_200" {
  rest_api_id = aws_api_gateway_rest_api.tf_bookings_store.id
  resource_id = aws_api_gateway_resource.bookings.id
  http_method = aws_api_gateway_method.bookings_method.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  depends_on = [aws_api_gateway_method.bookings_method]
}

resource "aws_api_gateway_integration" "bookings_lambda_integration" {
  http_method             = aws_api_gateway_method.bookings_method.http_method
  resource_id             = aws_api_gateway_resource.bookings.id
  rest_api_id             = aws_api_gateway_rest_api.tf_bookings_store.id
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.terraform_lambda_func.invoke_arn
  content_handling        = "CONVERT_TO_TEXT"
  depends_on              = [aws_api_gateway_method.bookings_method, aws_lambda_function.terraform_lambda_func]
}

# Terraform APIGateway Resources for 'payments'
resource "aws_api_gateway_method" "payments_method" {
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_auth.id
  http_method   = "ANY"
  resource_id   = aws_api_gateway_resource.payments.id
  rest_api_id   = aws_api_gateway_rest_api.tf_bookings_store.id
}

resource "aws_api_gateway_method_response" "payments_method_response_200" {
  rest_api_id = aws_api_gateway_rest_api.tf_bookings_store.id
  resource_id = aws_api_gateway_resource.payments.id
  http_method = aws_api_gateway_method.payments_method.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  depends_on = [aws_api_gateway_method.payments_method]
}

resource "aws_api_gateway_integration" "payments_lambda_integration" {
  http_method             = aws_api_gateway_method.payments_method.http_method
  resource_id             = aws_api_gateway_resource.payments.id
  rest_api_id             = aws_api_gateway_rest_api.tf_bookings_store.id
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.terraform_payment_lambda_func.invoke_arn
  content_handling        = "CONVERT_TO_TEXT"
  depends_on              = [aws_api_gateway_method.payments_method, aws_lambda_function.terraform_payment_lambda_func]
}

# Authorizer
resource "aws_api_gateway_authorizer" "cognito_auth" {
  name                   = "cognito_auth"
  type                   = "COGNITO_USER_POOLS"
  rest_api_id            = aws_api_gateway_rest_api.tf_bookings_store.id
  authorizer_uri         = aws_lambda_function.terraform_lambda_func.invoke_arn
  authorizer_credentials = aws_iam_role.invocation_role.arn
  provider_arns          = ["arn:aws:cognito-idp:${var.aws_region}:${var.aws_account_id}:userpool/${aws_cognito_user_pool.lambda_user_pool.id}"]
}

# Deployment
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.tf_bookings_store.id
  stage_name  = "beta"
  depends_on = [
    aws_api_gateway_integration.bookings_lambda_integration,
  aws_api_gateway_integration.payments_lambda_integration]
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
      "Resource": "[${aws_lambda_function.terraform_lambda_func.arn},${aws_lambda_function.terraform_payment_lambda_func.arn}]"
    }
  ]
}
EOF
}

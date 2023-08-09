
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

resource "aws_iam_role" "iam_for_payment_lambda" {
  name = "iam_for_payment_lambda"

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

resource "aws_iam_role" "iam_for_login_notification_lambda" {
  name = "iam_for_login_notification_lambda"

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
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      }
    ]
  })
}

resource "aws_iam_policy" "iam_policy_for_payment_lambda" {
  name        = "aws_iam_policy_for_terraform_aws_payment_lambda_role"
  path        = "/"
  description = "AWS IAM Policy for managing aws payment lambda role"
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

resource "aws_iam_policy" "iam_cognito_lambda_invocation_policy" {
  name        = "aws_iam_cognito_lambda_invocation_policy"
  path        = "/"
  description = "Grants Amazon Cognito a limited ability to invoke a Lambda function"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Id" : "default",
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

resource "aws_iam_role_policy_attachment" "attach_iam_dynamodb_privilege_policy_to_iam_role" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.iam_dynamodb_privilege_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

resource "aws_iam_role_policy_attachment" "attach_iam_payment_lambda_policy_to_iam_role" {
  role       = aws_iam_role.iam_for_payment_lambda.name
  policy_arn = aws_iam_policy.iam_policy_for_payment_lambda.arn
}

resource "aws_iam_role_policy_attachment" "attach_iam_login_notification_lambda_policy_to_iam_role" {
  role       = aws_iam_role.iam_for_login_notification_lambda.name
  policy_arn = aws_iam_policy.iam_cognito_lambda_invocation_policy.arn
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

# Lambda Function
resource "aws_lambda_function" "terraform_payment_lambda_func" {
  filename         = "${path.module}/../payments.zip"
  source_code_hash = filebase64sha256("${path.module}/../payments.zip")
  function_name    = "SimSafari_Lodge_Booking_Payment_API"
  role             = aws_iam_role.iam_for_payment_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.10"
  depends_on       = [aws_iam_role_policy_attachment.attach_iam_payment_lambda_policy_to_iam_role]

  environment {
    variables = {
      "APP_PAYFAST_MERCHANT_ID"          = var.payfast_merchant_id
      "APP_PAYFAST_MERCHANT_KEY"         = var.payfast_merchant_key
      "APP_PAYFAST_ONSITE_URL"           = var.payfast_onsite_url
      "APP_PAYFAST_PASSPHRASE"           = var.payfast_passphrase
      "APP_PAYFAST_CONFIRMATION_ADDRESS" = var.payfast_confirmation_address
      "APP_PAYFAST_EMAIL_CONFIRMATION"   = var.payfast_email_confirmation
    }
  }
}

# Lambda Function for Login Notifications and Logging
resource "aws_lambda_function" "terraform_login_notification_lambda_func" {
  filename         = "${path.module}/../login_notifications/lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/../login_notifications/lambda_function.zip")
  function_name    = "SimSafari_Lodge_Booking_Login_Notification"
  role             = aws_iam_role.iam_for_login_notification_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.10"

  environment {
    variables = {
      "APP_TELEGRAM_BOT_TOKEN" = var.telegram_bot_token
      "APP_TELEGRAM_CHAT_ID"   = var.telegram_chat_id
    }
  }
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

resource "aws_lambda_permission" "tf_payments_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.terraform_payment_lambda_func.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${aws_api_gateway_rest_api.tf_bookings_store.id}/*/${aws_api_gateway_method.payments_method.http_method}${aws_api_gateway_resource.payments.path}"
}

resource "aws_lambda_permission" "tf_login_notification_lambda" {
  statement_id  = "CSI_PostAuthentication"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.terraform_login_notification_lambda_func.function_name
  principal     = "cognito-idp.amazonaws.com"

  source_arn = "arn:aws:cognito-idp:${var.aws_region}:${var.aws_account_id}:userpool/${aws_cognito_user_pool.lambda_user_pool.id}"
}

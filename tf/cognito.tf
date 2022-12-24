resource "aws_cognito_user_pool" "lambda_user_pool" {
  name = "lambda_user_pool"

  username_attributes = ["phone_number", "email"]

  username_configuration {
    case_sensitive = false
  }

  schema {
    name                     = "name"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = false
    required                 = true

    string_attribute_constraints {
      min_length = 1
      max_length = 2048
    }
  }

  tags = var.common_tags
}

resource "aws_cognito_user_pool_client" "userpool_client" {
  name                                 = "cognito_userpool_client"
  user_pool_id                         = aws_cognito_user_pool.lambda_user_pool.id
  callback_urls                        = ["https://www.${var.domain_name}"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid", "phone", "profile"]
  supported_identity_providers         = ["COGNITO"]
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = replace(var.domain_name, ".co.za", "")
  user_pool_id = aws_cognito_user_pool.lambda_user_pool.id
}
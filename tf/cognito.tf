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
    mutable                  = true
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
  callback_urls                        = ["https://www.${var.domain_name}/user/login"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid", "phone", "profile"]
  supported_identity_providers         = ["COGNITO", aws_cognito_identity_provider.google_provider.provider_name]
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = replace(var.domain_name, ".co.za", "")
  user_pool_id = aws_cognito_user_pool.lambda_user_pool.id
}

resource "aws_cognito_user_pool_ui_customization" "custom_ui" {
  client_id = aws_cognito_user_pool_client.userpool_client.id

  image_file = filebase64("assets/bookings-logo-min.png")

  # Refer to the aws_cognito_user_pool_domain resource's
  # user_pool_id attribute to ensure it is in an 'Active' state
  user_pool_id = aws_cognito_user_pool_domain.main.user_pool_id
}

resource "aws_cognito_identity_provider" "google_provider" {
  user_pool_id  = aws_cognito_user_pool.lambda_user_pool.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    authorize_scopes              = "profile email openid"
    client_id                     = var.google_client_id
    client_secret                 = var.google_client_secret
    attributes_url                = "https://people.googleapis.com/v1/people/me?personFields="
    attributes_url_add_attributes = "true"
    authorize_url                 = "https://accounts.google.com/o/oauth2/v2/auth"
    oidc_issuer                   = "https://accounts.google.com"
    token_request_method          = "POST"
    token_url                     = "https://www.googleapis.com/oauth2/v4/token"
  }

  attribute_mapping = {
    email    = "email"
    name     = "name"
    username = "sub"
  }
}
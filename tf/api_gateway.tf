
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
  authorization = "NONE"
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

resource "aws_api_gateway_rest_api" "flag_api" {
  name = "flag-api"
}

resource "aws_api_gateway_resource" "flag_resource" {
  rest_api_id = aws_api_gateway_rest_api.flag_api.id
  parent_id   = aws_api_gateway_rest_api.flag_api.root_resource_id
  path_part   = "flag"
}

resource "aws_api_gateway_method" "get_flag_method" {
  rest_api_id   = aws_api_gateway_rest_api.flag_api.id
  resource_id   = aws_api_gateway_resource.flag_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.flag_api.id
  resource_id = aws_api_gateway_resource.flag_resource.id
  http_method = aws_api_gateway_method.get_flag_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_flag.invoke_arn
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_flag.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.flag_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.flag_api.id

  depends_on = [aws_api_gateway_integration.lambda_integration]
}

resource "aws_api_gateway_stage" "prod" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.flag_api.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id
}
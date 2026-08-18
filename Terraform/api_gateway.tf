resource "aws_apigatewayv2_api" "splitcloud_api" {
  name          = "splitcloud-API"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.splitcloud_api.id
  name        = "default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "creer_groupe_integration" {
  api_id                 = aws_apigatewayv2_api.splitcloud_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.creer_groupe.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "ajouter_depense_integration" {
  api_id                 = aws_apigatewayv2_api.splitcloud_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.ajouter_depense.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "lister_depenses_integration" {
  api_id                 = aws_apigatewayv2_api.splitcloud_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.lister_depenses.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "calculer_soldes_integration" {
  api_id                 = aws_apigatewayv2_api.splitcloud_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.calculer_soldes.invoke_arn
  payload_format_version = "2.0"
}


resource "aws_apigatewayv2_route" "creer_groupe_route" {
  api_id    = aws_apigatewayv2_api.splitcloud_api.id
  route_key = "POST /creer-groupe"
  target    = "integrations/${aws_apigatewayv2_integration.creer_groupe_integration.id}"

  authorization_type = "JWT"
  authorizer_id       = aws_apigatewayv2_authorizer.cognito_authorizer.id
}

resource "aws_apigatewayv2_route" "ajouter_depense_route" {
  api_id    = aws_apigatewayv2_api.splitcloud_api.id
  route_key = "POST /ajouter-depense"
  target    = "integrations/${aws_apigatewayv2_integration.ajouter_depense_integration.id}"

  authorization_type = "JWT"
  authorizer_id       = aws_apigatewayv2_authorizer.cognito_authorizer.id
}

resource "aws_apigatewayv2_route" "lister_depenses_route" {
  api_id    = aws_apigatewayv2_api.splitcloud_api.id
  route_key = "GET /lister-depenses"
  target    = "integrations/${aws_apigatewayv2_integration.lister_depenses_integration.id}"

  authorization_type = "JWT"
  authorizer_id       = aws_apigatewayv2_authorizer.cognito_authorizer.id
}

resource "aws_apigatewayv2_route" "calculer_soldes_route" {
  api_id    = aws_apigatewayv2_api.splitcloud_api.id
  route_key = "GET /calculer-soldes"
  target    = "integrations/${aws_apigatewayv2_integration.calculer_soldes_integration.id}"

  authorization_type = "JWT"
  authorizer_id       = aws_apigatewayv2_authorizer.cognito_authorizer.id
}





resource "aws_apigatewayv2_authorizer" "cognito_authorizer" {
  api_id           = aws_apigatewayv2_api.splitcloud_api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "cognito-authorizer"

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.splitcloud_client.id]
    issuer   = "https://cognito-idp.eu-west-1.amazonaws.com/${aws_cognito_user_pool.splitcloud_users.id}"
  }
}
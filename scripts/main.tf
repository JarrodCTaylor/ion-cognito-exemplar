provider "aws" {
  version = "~> 3.17.0"
  region = "us-east-1"
}

###########
# Variables
###########
locals {
  api_name                     = "Authed-Ion-Exemplar"
  region                       = "us-east-1"
  gateway_id                   = "XXXXXXX"  # Physical ID of the `HttpDirectApiGateway`. Found in Cloudformation Outputs tab of Compute Stack
  load_balancer_integration_id = "XXXXXXX"  # Physical ID of the `HttpDirectApiIntegration` found in Cloudformation Outputs tab of Compute Stack
}

###########
# Cognito Resources
###########

# =========
# The Cognito user_pool
resource "aws_cognito_user_pool" "pool" {
  name = "${local.api_name}-user-pool"
  password_policy {
    minimum_length    = 8
    require_uppercase = true
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
  }
  schema  {
    attribute_data_type = "String"
    name                = "email"
    required            = true
  }
  mfa_configuration        = "OFF"
  auto_verified_attributes = ["email"]
  alias_attributes         = ["email"]
  username_configuration  {
    case_sensitive = false
  }
}

# =========
# The Cognito client will be the bridge between the gateway and the user pool
resource "aws_cognito_user_pool_client" "pool_client" {
  name                = "${local.api_name}-user-pool-client"
  user_pool_id        = aws_cognito_user_pool.pool.id
  generate_secret     = false
  explicit_auth_flows = ["ALLOW_ADMIN_USER_PASSWORD_AUTH",
                         "ALLOW_CUSTOM_AUTH",
                         "ALLOW_USER_PASSWORD_AUTH",
                         "ALLOW_USER_SRP_AUTH",
                         "ALLOW_REFRESH_TOKEN_AUTH"]
}

# =========
# There is no direct way to create Cognito users with terraform
# A null_resource allows shelling out to the aws cli for the duties of
# creating a new user and setting the user's password to allow retrieving a token
resource "null_resource" "cognito_user" {

  triggers = {
    user_pool_id = aws_cognito_user_pool.pool.id
  }

  provisioner "local-exec" {
    command = "aws cognito-idp admin-create-user --user-pool-id ${aws_cognito_user_pool.pool.id} --username exemplarUser"
  }

  provisioner "local-exec" {
    command = "aws cognito-idp admin-set-user-password --user-pool-id ${aws_cognito_user_pool.pool.id} --username exemplarUser --password Password1- --permanent"
  }
}

###########
# API-Gateway Resources
###########

# =========
# Creating the public ANY route with the appropriate load balancer integration
resource "aws_apigatewayv2_route" "public" {
  api_id    = local.gateway_id
  route_key = "ANY /api/v1/public/{proxy+}"
  target    = "integrations/${local.load_balancer_integration_id}"
}

# =========
# Creating the gateway authorizer with the above created user pool and client
resource "aws_apigatewayv2_authorizer" "gw_auth" {
  api_id           = local.gateway_id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "${local.api_name}-authorizer"

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.pool_client.id]
    issuer   = "https://${aws_cognito_user_pool.pool.endpoint}"
  }
}

# =========
# Creating the authenticated ANY route with the appropriate load balancer integration
# and the above created authorizer
resource "aws_apigatewayv2_route" "authed" {
  api_id = local.gateway_id
  route_key = "ANY /api/v1/authed/{proxy+}"
  target = "integrations/${local.load_balancer_integration_id}"
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.gw_auth.id
}

# =========
# Creating a catch all OPTIONS route. (Only required for request from a browser)
resource "aws_apigatewayv2_route" "cors" {
  api_id = local.gateway_id
  route_key = "OPTIONS /{proxy+}"
}

###########
# Outputs
###########
output "user_pool" {
  value = aws_cognito_user_pool.pool.id
}

output "user_pool_client" {
  value = aws_cognito_user_pool_client.pool_client.id
}

output "api_url" {
  value = "https://${local.gateway_id}.execute-api.${local.region}.amazonaws.com"
}
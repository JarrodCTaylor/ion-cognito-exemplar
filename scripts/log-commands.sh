ion_api_gateway_endpoint=$(aws cloudformation describe-stacks --stack-name "$1" --query "Stacks[0].Outputs[?OutputKey=='IonApiGatewayEndpoint'].OutputValue" --output text)

# The following is done in two calls so as to avoid any concern about indeterminate value order in the response.
http_direct_integration=$(aws cloudformation describe-stack-resources --stack-name "$1" --query "StackResources[?LogicalResourceId=='HttpDirectApiIntegration'].PhysicalResourceId" --output text)
http_direct_gateway=$(aws cloudformation describe-stack-resources --stack-name "$1" --query "StackResources[?LogicalResourceId=='HttpDirectApiGateway'].PhysicalResourceId" --output text)

[[ $ion_api_gateway_endpoint =~ execute-api.([^,]+).amazonaws.com ]]
region="${BASH_REMATCH[1]}"

echo ""
echo "== Ensure Successful Initial Deployment =="
echo "curl '${ion_api_gateway_endpoint}/api/v1/public/ping'"
echo ""
echo "== Terraform Apply =="
echo "terraform apply -var \"aws_region=$region\" -var \"gateway_id=$http_direct_gateway\" -var \"lb_integration=$http_direct_integration\""

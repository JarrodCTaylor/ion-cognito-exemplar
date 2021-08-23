## Variables
vars=$(terraform output -json > tf-out.json)
apiUrl=$(jq -r '.api_url.value' tf-out.json)
userPool=$(jq -r '.user_pool.value' tf-out.json)
userPoolClient=$(jq -r '.user_pool_client.value' tf-out.json)
username=exemplarUser

UserToken=$(aws cognito-idp admin-initiate-auth --region us-east-1 --user-pool-id $userPool --client-id $userPoolClient --auth-flow ADMIN_NO_SRP_AUTH --auth-parameters USERNAME=$username,PASSWORD=Password1- | jq -r '.AuthenticationResult.IdToken')

echo "=== Testing unauthenticated request to public endpoint ${apiUrl}/api/v1/public/ping"
curl "${apiUrl}/api/v1/public/ping"
echo ""
echo ""
echo "=== Testing authenticated request to authed endpoint ${apiUrl}/api/v1/authed/say-hello"
curl "${apiUrl}/api/v1/authed/say-hello" -H "Authorization: $UserToken"
echo ""
echo ""
echo "=== Testing authenticated request using an invalid token to authed endpoint ${apiUrl}/api/v1/authed/say-hello"
curl "${apiUrl}/api/v1/authed/say-hello" -H "Authorization:  eyJraWQiOiJhN3RGKzBuaGtHU0NtVFg1Q3NpV2NueHRyMklIeTY4UFlrejArZGVwbitrPSIsImFsZy"

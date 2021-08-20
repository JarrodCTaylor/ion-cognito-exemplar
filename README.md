# Ion Cognito Exemplar

Source code that accompanies the [blog post](http://www.jarrodctaylor.com/posts/Cognito-Authenticated-For-Datomic-Cloud/) demonstrating how to setup
authenticated routes in Datomic cloud.

## Running locally

``` shell
clojure -Mlocal-server

## Test public endpoint
curl http://localhost:9874/api/v1/public/ping
```

## Deployment

*NOTE* Prior to deploying it is always a good idea to check that the app will
run locally.  The `-main` function in the core namespace will provide a
basic sanity check.

``` shell
clojure -m ion-cognito-exemplar.core
```

Add the correct system name in `ion-config.edn` and deploy to an ion.

## Terraform

You must provide values for the variables `gateway_id` and `load_balancer_integration_id` which can be found
in the cloudformation outputs tab of the compute stack as `HttpDirectApiGateway` and `HttpDirectApiIntegration`
respectively. Include these values in the main.tf script on lines 12 and 13.

Now, assuming terraform is installed, run the following:

``` sh
terraform init
terraform plan
terraform apply
```

When that completes successfully take note of the values logged for `user_pool`, `user_pool_client`
and `user_pool_client` as they will be needed in the final testing step.

## Testing it Out

Use the values logged by the terraform script to populate the variables
at the top of `scripts/test-endpoints.sh`.


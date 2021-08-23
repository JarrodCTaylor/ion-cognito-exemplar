# Ion Cognito Exemplar

Source code that accompanies the [blog post](http://www.jarrodctaylor.com/posts/Cognito-Authentication-For-Datomic-Cloud/) demonstrating how to setup
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
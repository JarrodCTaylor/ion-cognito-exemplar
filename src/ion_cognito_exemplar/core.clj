(ns ion-cognito-exemplar.core
  (:require
    [muuntaja.core :as m]
    [reitit.ring :as ring]
    [reitit.ring.middleware.muuntaja :as muuntaja]
    [ring.middleware.params :as params]
    [ion-cognito-exemplar.middleware.token-auth :refer [token-auth-mw]]
    [ion-cognito-exemplar.middleware.cors :refer [cors-mw options-mw]]))

;;; Authenticated routes
; Authenticated routes include the `token-auth-mw`. This middleware
; adds and :identity key to the request with the map value containing
; :username and :email. These values are decoded from the jwt token
; passed in the authorization header of the request. These routes are
; expected to be authenticated by cognito prior to being proxy to the application.
(defn say-hello-response [{{:keys [username]} :identity}]
    {:status 200
     :body {:message (str "Hello, " username)}})

(def authed-routes
  ["/authed"
   ["/say-hello" {:name ::say-hello
                  :get {:middleware [token-auth-mw]
                        :handler say-hello-response}}]])

;;; Public routes
(defn ping-response [_]
  {:status 200
   :body {:message "Pong'ing back"}})

(def public-routes
  ["/public"
   ["/ping" {:name ::ping
             :get {:handler ping-response}}]])

(def app
  (ring/ring-handler
    (ring/router
      ["/api/v1" [public-routes]
                 [authed-routes]]
      {:data {:muuntaja m/instance
              :middleware [options-mw
                           cors-mw
                           params/wrap-params
                           muuntaja/format-middleware]}})
    (ring/create-default-handler)))

(defn -main [& args]
  (println app)
  (println "This should pass the deploy check :)"))

(ns ion-cognito-exemplar.middleware.cors)

(def cors-headers {"Access-Control-Allow-Origin" "*"
                   "Access-Control-Allow-Methods" "GET, PUT, PATCH, POST, DELETE, OPTIONS"
                   "Access-Control-Allow-Headers" "Authorization, Content-Type"})

(def options-mw
  {:name ::cors-mw
   :summary "This will catch all OPTIONS preflight requests from the
             browser. It will always return a success for the purpose
             of the browser retrieving the response headers to validate CORS
             requests. Only needed for local dev as API gateway deals with this in prod"
   :wrap (fn [handler]
           (fn [request]
             (if (= :options (:request-method request))
               {:status 200 :body "" :headers cors-headers}
               (handler request))))})

(defn cors-mw
  "Cross-origin Resource Sharing (CORS) middleware. Allow requests from all
   origins, all http methods and Authorization and Content-Type headers."
  [handler]
  (fn [request]
    (assoc (handler request) :headers cors-headers)))

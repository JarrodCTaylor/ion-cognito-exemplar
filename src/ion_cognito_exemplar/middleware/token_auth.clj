(ns ion-cognito-exemplar.middleware.token-auth
  (:require
    [clojure.string :as str]
    [muuntaja.core :as m])
  (:import java.util.Base64))

(defn decode-jwt [jwt]
  (let [[_ payload _] (str/split jwt #"\.")]
    (String. (.decode (Base64/getDecoder) ^String payload))))

(def token-auth-mw
  {:name ::token-authN
   :summary "Inject a map containing `:username` and `:email` into the key `:identity` on the request.
             The application uses AWS Cognito for request authorization in front of the application.
             By the time we are at application router we are confident we have a valid token. This simply
             decodes the token and injects the user identity into the request."
   :wrap (fn [handler]
           (fn [request]
             (let [jwt (-> request :headers (get "authorization"))
                   decoded-token (->> jwt decode-jwt (m/decode "application/json"))]
               (handler (assoc request :identity {:username (:cognito:username decoded-token)
                                                  :email (:email decoded-token)})))))})

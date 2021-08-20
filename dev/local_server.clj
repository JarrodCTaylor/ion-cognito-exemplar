(ns local-server
  (:require
    [org.httpkit.server :as httpkit]
    [ion-cognito-exemplar.core :refer [app]]))

(def server (atom nil))

(defn start-authed []
  (->> (httpkit/run-server app {:port 9874
                                :max-body 100000000
                                :join false})
       (reset! server))
  (println "Authed API started on port:" 9874))

(defn -main [& args]
  (start-authed))

(defn stop []
  (@server))

(comment
  (-main)

  (stop))

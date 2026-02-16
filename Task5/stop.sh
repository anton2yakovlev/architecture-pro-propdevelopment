kubectl delete pod front-end-app back-end-api-app admin-front-end-app admin-back-end-api-app
kubectl delete service front-end-app back-end-api-app admin-front-end-app admin-back-end-api-app
kubectl delete networkpolicy non-admin-api-allow front-end-allow admin-api-allow admin-front-end-allow

#!/bin/bash

#get the project ID
export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null) 

gsutil -m cp -r gs://spls/gsp053/orchestrate-with-kubernetes .
cd orchestrate-with-kubernetes/kubernetes

sed -i 's/2.0.0/1.0.0/' deployments/auth.yaml

gcloud container clusters get-credentials bootcamp --region us-central1 --project $PROJECT_ID

kubectl create -f deployments/auth.yaml
kubectl create -f services/auth.yaml
kubectl create -f deployments/hello.yaml
kubectl create -f services/hello.yaml
kubectl create secret generic tls-certs --from-file tls/
kubectl create configmap nginx-frontend-conf --from-file=nginx/frontend.conf
kubectl create -f deployments/frontend.yaml
kubectl create -f services/frontend.yaml
kubectl create -f deployments/hello-canary.yaml

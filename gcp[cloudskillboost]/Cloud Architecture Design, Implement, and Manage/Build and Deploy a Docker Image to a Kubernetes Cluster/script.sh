#!/bin/bash
export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null) 
gsutil cp -r gs://$PROJECT_ID .


cd $PROJECT_ID/echo-web

gcloud builds submit --tag gcr.io/$PROJECT_ID/echo-web:v1
gcloud container clusters get-credentials echo-cluster --zone us-central1-a --project $PROJECT_ID

sed -i 's/echoweb/echo-web/' manifests/echoweb-deployment.yaml
sed -i 's/google-samples/'$PROJECT_ID'/' manifests/echoweb-deployment.yaml

kubectl apply -f manifests/
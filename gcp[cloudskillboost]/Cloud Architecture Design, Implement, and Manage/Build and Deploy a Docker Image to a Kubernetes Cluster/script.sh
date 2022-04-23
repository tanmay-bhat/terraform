#!/bin/bash

wget https://www.cloudskillsboost.google/instructions/2786040/download

tar -xzvf echo-web.tar.gz 

cd resources-echo-web

export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null) 
Docker build -t gcr.io/$PROJECT_ID/echo-web:v1 .

gcloud container clusters get-credentials echo-cluster --region us-central1 --project $PROJECT_ID

sed -i 's/echoweb/echo-web/' manifests/echoweb-deployment.yaml
sed -i 's/google-samples/'$PROJECT_ID'/' manifests/echoweb-deployment.yaml
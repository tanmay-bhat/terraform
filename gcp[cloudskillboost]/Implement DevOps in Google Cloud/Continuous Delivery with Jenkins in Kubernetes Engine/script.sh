#!/bin/bash

#get the project ID
export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null) 

gcloud container clusters get-credentials jenkins-cd --zone us-east1-d

helm repo add jenkins https://charts.jenkins.io
helm repo update

gsutil cp gs://spls/gsp330/values.yaml jenkins/values.yaml

helm install cd jenkins/jenkins -f jenkins/values.yaml --wait

kubectl create clusterrolebinding jenkins-deploy --clusterrole=cluster-admin --serviceaccount=default:cd-jenkins

export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/component=jenkins-master" -l "app.kubernetes.io/instance=cd" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward $POD_NAME 8080:8080 >> /dev/null &

cd sample-app
kubectl create ns production
kubectl apply -f k8s/production -n production
kubectl apply -f k8s/canary -n production
kubectl apply -f k8s/services -n production
kubectl scale deployment gceme-frontend-production -n production --replicas 4
export FRONTEND_SERVICE_IP=$(kubectl get -o jsonpath="{.status.loadBalancer.ingress[0].ip}" --namespace=production services gceme-frontend)
curl http://$FRONTEND_SERVICE_IP/version

git init
git config credential.helper gcloud.sh
git remote add origin https://source.developers.google.com/p/$DEVSHELL_PROJECT_ID/r/default
git config --global user.email "foo@foo.com"
git config --global user.name "foo"
git add .
git commit -m "Initial commit"
git push origin master

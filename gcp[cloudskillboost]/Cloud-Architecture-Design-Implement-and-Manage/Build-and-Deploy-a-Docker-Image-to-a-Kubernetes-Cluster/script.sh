#!/bin/bash
export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null) 
gsutil cp -r gs://$PROJECT_ID .

cd $PROJECT_ID/
tar -xzvf echo-web.tar.gz
cd echo-web

gcloud builds submit --tag gcr.io/$PROJECT_ID/echo-app:v1
gcloud container clusters get-credentials echo-cluster --zone us-central1-a --project $PROJECT_ID

cd manifests


cat <<EOF > echoweb-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echo-web
  labels:
    app: echo
spec:
  selector:
    matchLabels:
      app: echo
  template:
    metadata:
      labels:
        app: echo
    spec:
      containers:
      - name: echo-app
        image: gcr.io/qwiklabs-gcp-00-0660f19edbb5/echo-app:v1
        ports:
        - containerPort: 8000
EOF

cat <<EOF > echoweb-ingress-static-ip.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: echoweb
  annotations:
    kubernetes.io/ingress.global-static-ip-name: echoweb-ip
  labels:
    app: echo
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: echoweb-backend
            port:
              number: 80
---
apiVersion: v1
kind: Service
metadata:
  name: echoweb-backend
  labels:
    app: echo
spec:
  type: NodePort
  selector:
    app: echo
    tier: web
  ports:
  - port: 80
    targetPort: 8000
EOF

sed -i 's/google-samples/'$PROJECT_ID'/' echoweb-deployment.yaml
kubectl apply -f .
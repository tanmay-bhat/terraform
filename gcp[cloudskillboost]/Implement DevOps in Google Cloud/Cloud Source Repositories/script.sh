#!/bin/bash

#get the project ID
export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null) 

#clone created repo, add test files and push to rmeote repo
gcloud source repos clone REPO_DEMO
cd REPO_DEMO
echo 'Hello World!' > myfile.txt
git config --global user.email "foo@example.com"
git config --global user.name "foo"
git add myfile.txt
git commit -m "First file using Cloud Source Repositories" myfile.txt
git push origin master
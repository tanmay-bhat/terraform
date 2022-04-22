#!/bin/bash

#clone git repo
git clone https://github.com/GoogleCloudPlatform/gcf-automated-resource-cleanup.git 

#get the project ID
export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null) 


#sed to replace project id with your project id in python file
cd gcf-automated-resource-cleanup/unattached-pd && sed -i '/^project/s/=.*$/= '"'$PROJECT_ID'"'/' ./main.py


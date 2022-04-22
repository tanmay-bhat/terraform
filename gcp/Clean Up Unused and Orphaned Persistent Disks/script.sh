#!/bin/bash

#clone git repo
git clone https://github.com/GoogleCloudPlatform/gcf-automated-resource-cleanup.git 

export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)


cd gcf-automated-resource-cleanup/unattached-pd

#replace project id with your project id in python file
sed -i '/^project/s/=.*$/= '"$PROJECT_ID"'/' ./main.py


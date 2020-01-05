#!/bin/bash

source .deployment.env

./resolution-secrets.sh

# --
# [@] now we initialize the hugo project for your resume
# --

# - A bit of interpolation first
cp oci/jinja2.Dockerfile oci/Dockerfile
sed -i "s#BUMBLEBEE_HOME_INSIDE_CONTAINER_JINJA2_VAR#$BUMBLEBEE_HOME_INSIDE_CONTAINER#g" oci/Dockerfile
# docker-compose up -d init_projet_hugo
# docker-compose up -d --build --force-recreate init_hugo_resume && docker-compose logs -f init_hugo_resume
docker-compose up -d

echo "docker-compose config "
echo "docker-compose logs -f  "
echo " "

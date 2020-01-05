#!/bin/bash

source .deployment.env
echo ""
echo " [Creating Pipeline's Robot's Linux operator on Local Deployment Target ] "
echo ""

clear
./resolution-secrets.sh

echo " "
echo " Vérifiez que vous pouvez vous authentifier au serveur SSH avec"
echo " le user linux [beeio] et sans le mot de passe [beebee]"
echo " mais avec la clefs privée SSH [BUMBLEBEE_SSH_PRIVATE_KEY_FULLPATH=[$BUMBLEBEE_SSH_PRIVATE_KEY_FULLPATH]]"
echo " "
echo " [ssh -i $BUMBLEBEE_SSH_PRIVATE_KEY_FULLPATH beeio@poste-devops-typique]"
echo " "


echo ""
echo " [Pulling Third party Docker Images : ] "
echo ""
# for the workers :
docker pull thecodingmachine/gotenberg:6
docker pull node:8.16.2-stretch
# for the tasks :
docker pull ansible/centos7-ansible:stable
docker pull debian:stretch-slim
docker pull willhallonline/ansible:2.8-centos
# --
# [@] now we initialize the hugo project for your resume
# --

# - A bit of interpolation first
cp oci/workers/init_hugo_resume/jinja2.Dockerfile oci/workers/init_hugo_resume/Dockerfile
sed -i "s#BUMBLEBEE_HOME_INSIDE_CONTAINER_JINJA2_VAR#$BUMBLEBEE_HOME_INSIDE_CONTAINER#g" oci/workers/init_hugo_resume/Dockerfile
# docker-compose up -d init_projet_hugo
# docker-compose up -d --build --force-recreate init_hugo_resume && docker-compose logs -f init_hugo_resume
docker-compose up -d --build --force-recreate init_hugo_resume

echo "docker-compose config "
echo "docker-compose logs -f init_hugo_resume "
echo " "

# --
# Permet d'attendre, pour être sûr que l'initialisation du
# projet hugo soient terminée et bien disponible sur le premier commit
# sur le Pipeline [DNA]
# --
docker-compose logs -f init_hugo_resume

# --
# [@] now we build the hugo project for your resume
# --

# - a bit of interpolation first
#
# [oci/workers/bootstraper/Dockerfile] has already been interpolated.
# and both your resume and websites use the exact same hugo build process;
# sed -i "s#BUMBLEBEE_HOME_INSIDE_CONTAINER_JINJA2_VAR#$BUMBLEBEE_HOME_INSIDE_CONTAINER#g" oci/workers/bootstraper/Dockerfile
# docker-compose up -d build_hugo_resume
cp oci/workers/hugo-build/jinja2.Dockerfile oci/workers/hugo-build/Dockerfile
sed -i "s#BUMBLEBEE_HOME_INSIDE_CONTAINER_JINJA2_VAR#$BUMBLEBEE_HOME_INSIDE_CONTAINER#g" oci/workers/hugo-build/Dockerfile
# docker-compose up -d --build --force-recreate build_hugo_resume && docker-compose logs -f build_hugo_resume
docker-compose up -d --build --force-recreate build_hugo_resume


echo " "
echo " finished hugo building your resume "
echo " "
echo " You can now check on the Pipeline DNA, that a [public/] subfolder has been created bythe hugo build process. "
echo " "
echo " please now locally deploy from Pipeline DNA, using an [Ansible Playbook] "
echo " "

docker-compose logs -f build_hugo_resume
# --
# Permet d'attendre, pour être sûr que le build hugo du
# projet hugo soient terminé et le contenu de public bien
# sur le deuxième commit sur le Pipeline [DNA]
# --


# --
# [@] now we PREPARE DEPLOYMENT TARGET :
# --
# -
#    => Terraforming if neccessary, the needed MAchine Running Docker-Compose
#    => deploys the [docker-compose.yml] to [LOCAL_DEPLOYMENT_TARGET_DOCKER_COMPOSE_HOME]
#
# Before executing this script, you must git clone :
# [$(git remote -v |head -n 1 | awk '{print $2}')]
# Inside [$LOCAL_DEPLOYMENT_TARGET_DOCKER_COMPOSE_HOME]
# export URI_SSH_TO_DEPLOYMENT_TARGET_RECIPE_GIT_REPO=$(git remote -v |head -n 1 | awk '{print $2}')

sudo mkdir -p $LOCAL_DEPLOYMENT_TARGET_DOCKER_COMPOSE_HOME
sudo chown -R jibl:jibl $LOCAL_DEPLOYMENT_TARGET_DOCKER_COMPOSE_HOME
git clone $URI_SSH_TO_DEPLOYMENT_TARGET_RECIPE_GIT_REPO $LOCAL_DEPLOYMENT_TARGET_DOCKER_COMPOSE_HOME


cp $LOCAL_DEPLOYMENT_TARGET_DOCKER_COMPOSE_HOME/deployment-targets/local/oci/local_deploy/jinja2.Dockerfile $LOCAL_DEPLOYMENT_TARGET_DOCKER_COMPOSE_HOME/deployment-targets/local/oci/local_deploy/Dockerfile
sed -i "s#BUMBLEBEE_HOME_INSIDE_CONTAINER_JINJA2_VAR#$BUMBLEBEE_HOME_INSIDE_CONTAINER#g" $LOCAL_DEPLOYMENT_TARGET_DOCKER_COMPOSE_HOME/deployment-targets/local/oci/local_deploy/Dockerfile

# We also need the secrets needed by the deployement target (secrets resolution)
mkdir -p $LOCAL_DEPLOYMENT_TARGET_DOCKER_COMPOSE_HOME/deployment-targets/local/.robots/$BUMBLEBEE_ID
sudo cp -fR $BUMBLEBEE_SECRET_VAULT_OUTSIDE_CONTAINER $LOCAL_DEPLOYMENT_TARGET_DOCKER_COMPOSE_HOME/deployment-targets/local/.robots/$BUMBLEBEE_ID

echo ""
echo " DEBUG : verifier que [$BUMBLEBEE_SECRET_VAULT_OUTSIDE_CONTAINER] a bien été copié dans [$LOCAL_DEPLOYMENT_TARGET_DOCKER_COMPOSE_HOME/deployment-targets/local/.robots/$BUMBLEBEE_ID]  "
echo ""
#
# exit 0
sudo chown -R $LOCAL_DEPLOYMENT_TARGET_BUMBLEBEE_USERNAME:$LOCAL_DEPLOYMENT_TARGET_BUMBLEBEE_USERNAME $LOCAL_DEPLOYMENT_TARGET_DOCKER_COMPOSE_HOME

#
# then [LOCAL_DEPLOYMENT_TARGET_BUMBLEBEE_USERNAME] will be able to execute docker-compose commands with the [docker-compose.yml]  inside [$LOCAL_DEPLOYMENT_TARGET_DOCKER_COMPOSE_HOME/deployment-targets/local]
#

#
# - Finally, a bit of interpolation before launching [resume_local_deploy] task
#
cp oci/tasks/local_deploy_resume/jinja2.Dockerfile oci/tasks/local_deploy_resume/Dockerfile
sed -i "s#BUMBLEBEE_HOME_INSIDE_CONTAINER_JINJA2_VAR#$BUMBLEBEE_HOME_INSIDE_CONTAINER#g" oci/tasks/local_deploy_resume/Dockerfile


# --
# [@] now we locally DEPLOYHUGO PROJECT FOR THE RESUME
# --
docker-compose -f docker-compose.flow.yml up -d --build --force-recreate resume_local_deploy

echo " "
echo " finished local deploy of your resume "
echo " "

echo " ---------------------------- "
echo " ---------------------------- "
echo "  Pour vérifier l'exécution :"
echo "  des workers :"
echo " ---------------------------- "
echo "  docker-compose logs -f "
echo " ---------------------------- "
echo " ---------------------------- "
echo "  Pour vérifier l'exécution :"
echo "  des tasks :"
echo " ---------------------------- "
echo "  docker-compose -f docker-compose.flow.yml logs -f "
echo " ---------------------------- "
docker-compose -f docker-compose.flow.yml logs -f resume_local_deploy


# --
# [@] now we generate the PDF from your resume, and
#     push generated PDF to Pipeline DNA
# --

# we need the tool that does the PDF generation :
# pleins de détails techniques sur la génération du PDF :
# https://gitlab.com/second-bureau/mon.bureau/site-internet-pro/pipeline/issues/1
#
docker-compose up -d gotenberg_service
# it's really dirty, to wait like that just to be sure gotenberg is up n running...
# Simple to start with, we'll later use HEALTHCHECKS in a container orchestrator like K8S.
sleep 3s
# --->>> now invoking worker

# - a bit of interpolation first
#
if [ -f oci/workers/resume_to_pdf/previous.Dockerfile ]; then
  rm oci/workers/resume_to_pdf/previous.Dockerfile
fi;
if [ -f oci/workers/resume_to_pdf/Dockerfile ]; then
  cp oci/workers/resume_to_pdf/Dockerfile oci/workers/resume_to_pdf/previous.Dockerfile
  echo "previous [oci/workers/resume_to_pdf/Dockerfile] saved to [oci/workers/resume_to_pdf/previous.Dockerfile]. Save it somewhere else if you want to keepit, it will be deleted during next pipeline execution"
  rm oci/workers/resume_to_pdf/Dockerfile
fi;

cp oci/workers/resume_to_pdf/jinja2.Dockerfile oci/workers/resume_to_pdf/Dockerfile
sed -i "s#BUMBLEBEE_HOME_INSIDE_CONTAINER_JINJA2_VAR#$BUMBLEBEE_HOME_INSIDE_CONTAINER#g" oci/workers/resume_to_pdf/Dockerfile
docker-compose up -d --build --force-recreate resume_to_pdf && docker-compose logs -f resume_to_pdf
echo " "
echo " finished generating your PDF resume, check"
echo " its presence on Pipeline's DNA [$SSH_URI_TO_PIPELINE_DNA] "
echo " "



docker-compose logs -f resume_to_pdf
echo " ---------------------------- "
echo "  POINT ARRET DEBUG : APRES LA GENERATION DU PDF POUR LE CV"
echo " ---------------------------- "
echo "  Pour vérifier l'exécution :"
echo "  des workers :"
echo " ---------------------------- "
echo "  docker-compose logs -f "
echo " ---------------------------- "
echo " ---------------------------- "
echo "  Pour vérifier l'exécution :"
echo "  des tasks :"
echo " ---------------------------- "
echo "  docker-compose -f docker-compose.flow.yml logs -f "
echo " ---------------------------- "



# --
# [@] now we initialize the hugo project for your website
#     So we [git rm] everything in the Pipeline DNA
#     except the generated PDF for your resume : we will
#     include it in the generated hugo project for your website.
# --

# - a bit of interpolation first
if [ -f oci/workers/bootstraper/previous.Dockerfile ]; then
  rm oci/workers/bootstraper/previous.Dockerfile
fi;
if [ -f oci/workers/bootstraper/Dockerfile ]; then
  cp oci/workers/bootstraper/Dockerfile oci/workers/bootstraper/previous.Dockerfile
  echo "previous [oci/workers/bootstraper/Dockerfile] saved to [oci/workers/bootstraper/previous.Dockerfile]. Save it somewhere else if you want to archive it, it will be deleted during next pipeline execution"
  rm oci/workers/bootstraper/Dockerfile
fi;
cp oci/workers/bootstraper/jinja2.Dockerfile oci/workers/bootstraper/Dockerfile
sed -i "s#BUMBLEBEE_HOME_INSIDE_CONTAINER_JINJA2_VAR#$BUMBLEBEE_HOME_INSIDE_CONTAINER#g" oci/workers/bootstraper/Dockerfile
# docker-compose up -d init_projet_hugo
docker-compose up -d --build --force-recreate init_projet_hugo && docker-compose logs -f init_projet_hugo

echo "docker-compose config "
echo "docker-compose logs -f init_projet_hugo "
echo " "


docker-compose logs -f init_projet_hugo


# --
# [@] now we build the hugo project for your website, and
#     push build result to Pipeline DNA
#     This worker will download the generated PDF for your resume
# --

# - a bit of interpolation first
#
if [ -f oci/workers/hugo-build/previous.Dockerfile ]; then
  rm oci/workers/hugo-build/previous.Dockerfile
fi;
if [ -f oci/workers/hugo-build/Dockerfile ]; then
  cp oci/workers/hugo-build/Dockerfile oci/workers/hugo-build/previous.Dockerfile
  echo "previous [oci/workers/hugo-build/Dockerfile] saved to [oci/workers/hugo-build/previous.Dockerfile]. Save it somewhere else if you want to archive it, it will be deleted during next pipeline execution"
  rm oci/workers/hugo-build/Dockerfile
fi;
cp oci/workers/hugo-build/jinja2.Dockerfile oci/workers/hugo-build/Dockerfile
sed -i "s#BUMBLEBEE_HOME_INSIDE_CONTAINER_JINJA2_VAR#$BUMBLEBEE_HOME_INSIDE_CONTAINER#g" oci/workers/hugo-build/Dockerfile

docker-compose up -d --build --force-recreate build_hugo && docker-compose logs -f build_hugo



docker-compose logs -f build_hugo

echo " ---------------------------- "
echo "  POINT ARRET DEBUG : APRES LE INIT HUGO ET LE HUGO BUILD POUR MON SITE WEB PRO"
echo " ---------------------------- "
echo "  Pour vérifier l'exécution :"
echo "  des workers :"
echo " ---------------------------- "
echo "  docker-compose logs -f init_projet_hugo "
echo "  docker-compose logs -f build_hugo  "
echo " ---------------------------- "
echo " ---------------------------- "
echo "  Pour vérifier l'exécution :"
echo "  des tasks :"
echo " ---------------------------- "
echo "  docker-compose -f docker-compose.flow.yml logs -f "
echo " ---------------------------- "



# --
# [@] now we locally deploy the hugo project for your website
# --

# - a bit of interpolation first
#

# ICIIIIIIIIIIIIIIIIII

#
# then [LOCAL_DEPLOYMENT_TARGET_BUMBLEBEE_USERNAME] will be able to execute docker-compose commands with the [docker-compose.yml]  inside [$LOCAL_DEPLOYMENT_TARGET_DOCKER_COMPOSE_HOME/deployment-targets/local]
#

#
# - Finally, a bit of interpolation before launching [resume_local_deploy] task
#
cp oci/tasks/deploy_local_website/jinja2.Dockerfile oci/tasks/deploy_local_website/Dockerfile
sed -i "s#BUMBLEBEE_HOME_INSIDE_CONTAINER_JINJA2_VAR#$BUMBLEBEE_HOME_INSIDE_CONTAINER#g" oci/tasks/deploy_local_website/Dockerfile

# --
# [@] now we locally DEPLOY HUGO PROJECT FOR THE WEBSITE
# --
docker-compose -f docker-compose.flow.yml up -d --build --force-recreate deploy_local_website && docker-compose logs -f deploy_local_website

echo " "
echo " finished local deploy of your website to [http://${LOCAL_DEPLOYMENT_TARGET_HOSTNAME}:8082/] "
echo " "

docker-compose -f docker-compose.flow.yml logs -f deploy_local_website
echo " ---------------------------- "
echo " ---------------------------- "
echo "  Pour vérifier l'exécution :"
echo "  des workers :"
echo " ---------------------------- "
echo "  docker-compose logs -f "
echo " ---------------------------- "
echo " ---------------------------- "
echo "  Pour vérifier l'exécution :"
echo "  des tasks :"
echo " ---------------------------- "
echo "  docker-compose -f docker-compose.flow.yml logs -f "
echo " ---------------------------- "
exit 0


### --- deploying to Github Pages, using hugo build result in [./public], pulled from Pipeline's DNA

### --- Pulling latest hugo built static site, from Pipeline DNA, to deploy it to github pages."
# - a bit of interpolation first
sed -i "s#BUMBLEBEE_HOME_INSIDE_CONTAINER_JINJA2_VAR#$BUMBLEBEE_HOME_INSIDE_CONTAINER#g" oci/workers/deploy-to-github-pages/Dockerfile
# docker-compose up -d init_projet_hugo
docker-compose up -d --build --force-recreate gh_pages_deploy && docker-compose logs -f gh_pages_deploy




# ------------------------------------------------------------------------
# ------------------------------------------------------------------------
# ------------------------------------------------------------------------
# ------------------------------------------------------------------------
# ------------------------------------------------------------------------
#
# Liste des conteneurs utilisés, pour nettoyage du [docker-comose.yml]
#  - base_pipeline_worker
#  - init_projet_hugo
#  - build_hugo
#  - cccc
#  - cccc
#  - cccc
#  - cccc
#
#
#
#
#
#
#
#
#
# ------------------------------------------------------------------------
# ------------------------------------------------------------------------
# ------------------------------------------------------------------------
# ------------------------------------------------------------------------
# ------------------------------------------------------------------------



# ------------------------------------------------------------------------
# ------------------------------------------------------------------------
# ------------------------------------------------------------------------
# -- [*] Pipline workers : executing build tasksinvoking ansible playbooks to either:
# --  ++> execute build, and test workers
# --  ++> or execute standard operations on deployment targets
# -- [*] Pipline tasks : invoking ansible playbooks to either:
# --  ++> execute workers, to execute build tasks, and test tasks
# --  ++> or execute standard operations on deployment targets
# ------------------------------------------------------------------------
# ------------------------------------------------------------------------
# ------------------------------------------------------------------------

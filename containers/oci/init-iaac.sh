#!/bin/bash


# set -e

echo " --------------------------------------------------------------------------------"
echo " debut [init-iaac.sh]"
# echo " execution de : "
# echo " [chown -R node:node $BUMBLEBEE_HOME_INSIDE_CONTAINER] : "
# echo " --------------------------------------------------------------------------------"
# chown -R node:node $BUMBLEBEE_HOME_INSIDE_CONTAINER
echo " --------------------------------------------------------------------------------"

# BUMBLEBEE_HOME_INSIDE_CONTAINER/secrets/.ssh  is the secrets home...
mkdir -p $BUMBLEBEE_HOME_INSIDE_CONTAINER/.secrets/.ssh


echo " --------------------------------------------------------------------------------"
echo " dans [init-iaac.sh] VERIFICATION DU CONTENU DE [$BUMBLEBEE_HOME_INSIDE_CONTAINER/.secrets] : "
echo " --------------------------------------------------------------------------------"
ls -allh $BUMBLEBEE_HOME_INSIDE_CONTAINER/.secrets
echo " --------------------------------------------------------------------------------"


echo " --------------------------------------------------------------------------------"
echo " dans [init-iaac.sh] VERIFICATION DU CONTENU DE [$BUMBLEBEE_HOME_INSIDE_CONTAINER/.secrets/.ssh] : "
echo " --------------------------------------------------------------------------------"
ls -allh $BUMBLEBEE_HOME_INSIDE_CONTAINER/.secrets/.ssh
echo " --------------------------------------------------------------------------------"

echo " --------------------------------------------------------------------------------"
echo " --------------------------------------------------------------------------------"
echo " dans [init-iaac.sh] [whoami=[$(whoami)]] : "
echo " --------------------------------------------------------------------------------"



chmod 700 $BUMBLEBEE_HOME_INSIDE_CONTAINER/.secrets/.ssh


# chmod 644 /root/.ssh/id_rsa.pub
chmod 644 $BUMBLEBEE_HOME_INSIDE_CONTAINER/.secrets/.ssh/$BUMBLEBEE_SSH_PUBLIC_KEY_FILENAME
# chmod 600 /root/.ssh/id_rsa
chmod 600 $BUMBLEBEE_HOME_INSIDE_CONTAINER/.secrets/.ssh/$BUMBLEBEE_SSH_PRIVATE_KEY_FILENAME

#
# Pegasus Robots Git settings  "Jean-Baptiste-lasselle"   / "jean.baptiste.lasselle.pegasus@gmail.com"
#

git config --global user.name "bumblebee.pegasus.devops"
git config --global user.email "bumblebee.pegasus@gmail.com"


# ssh CLIENT config
echo "PasswordAuthentication no" ~/.ssh/config

# SSH known hostnames

# Root user's default [known_hosts] file home folder
mkdir -p ~/.ssh

# ssh-keygen  -o PasswordAuthentication no
touch ~/.ssh/known_hosts
ssh-keygen -R $PIPELINE_GIT_SERVICE_PROVIDER_HOSTNAME
ssh-keyscan -H $PIPELINE_GIT_SERVICE_PROVIDER_HOSTNAME >> ~/.ssh/known_hosts

echo " jbl - [cat ~/.ssh/known_hosts]"
cat ~/.ssh/known_hosts

echo " debug jbl"
chmod 700 $BUMBLEBEE_HOME_INSIDE_CONTAINER/.secrets/.ssh

# chmod 644 /root/.ssh/id_rsa.pub
chmod 644 $BUMBLEBEE_HOME_INSIDE_CONTAINER/.secrets/.ssh/$BUMBLEBEE_SSH_PRIVATE_KEY_FILENAME
# chmod 600 /root/.ssh/id_rsa
chmod 600 $BUMBLEBEE_HOME_INSIDE_CONTAINER/.secrets/.ssh/$BUMBLEBEE_SSH_PRIVATE_KEY_FILENAME


ssh -vTai $BUMBLEBEE_HOME_INSIDE_CONTAINER/.secrets/.ssh/$BUMBLEBEE_SSH_PRIVATE_KEY_FILENAME git@$PIPELINE_GIT_SERVICE_PROVIDER_HOSTNAME

export GIT_SSH_COMMAND=$BUMBLEBEE_GIT_SSH_COMMAND


echo "BUMBLEBEE_GIT_SSH_COMMAND=[$BUMBLEBEE_GIT_SSH_COMMAND]"
echo "GIT_SSH_COMMAND=[$GIT_SSH_COMMAND]"

echo "End of IAAC Cycle initialisation, just BEFORE Piepeline Sep execution takes place into workspace."
pwd
ls -allh $BUMBLEBEE_WORKSPACE_INSIDE_CONTAINER

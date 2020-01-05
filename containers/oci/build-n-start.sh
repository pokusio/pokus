#!/bin/bash




export GIT_SSH_COMMAND=$BUMBLEBEE_GIT_SSH_COMMAND
# export GIT_SSH_COMMAND="ssh -Tvvvai '$BUMBLEBEE_HOME_INSIDE_CONTAINER/.secrets/.ssh/$BUMBLEBEE_SSH_PRIVATE_KEY_FILENAME' "

echo " # ////////// ----------------------------- ////////////// "
echo " "
echo " "
echo "    VALEUR GIT_SSH_COMMAND=[$GIT_SSH_COMMAND] "
echo " "
echo " # ////////// ----------------------------- ////////////// "
echo " "
echo " "

chmod +x ./init-iaac.sh
./init-iaac.sh

# ssh -Tvvvai $BUMBLEBEE_HOME_INSIDE_CONTAINER/.secrets/.ssh/$BUMBLEBEE_SSH_PRIVATE_KEY_FILENAME git@$PIPELINE_GIT_SERVICE_PROVIDER_HOSTNAME


echo " --------------------------------------------------------------------------------"
echo " dans [build-n-start.sh], juste avant git clone "
echo " --------------------------------------------------------------------------------"
echo " VERIFICATION DU CONTENU DE [$BUMBLEBEE_HOME_INSIDE_CONTAINER/.secrets] : "
echo " --------------------------------------------------------------------------------"
ls -allh $BUMBLEBEE_HOME_INSIDE_CONTAINER/.secrets
echo " --------------------------------------------------------------------------------"


echo " --------------------------------------------------------------------------------"
echo " dans [build-n-start.sh], juste avant git clone "
echo " --------------------------------------------------------------------------------"
echo " VERIFICATION DU CONTENU DE [$BUMBLEBEE_HOME_INSIDE_CONTAINER/.secrets/.ssh] : "
echo " --------------------------------------------------------------------------------"
ls -allh $BUMBLEBEE_HOME_INSIDE_CONTAINER/.secrets/.ssh

echo " --------------------------------------------------------------------------------"
echo " --------------------------------------------------------------------------------"
echo " dans [build-n-start.sh], juste avant git clone "
echo " --------------------------------------------------------------------------------"
echo " VERIFICATION DU CONTENU DE [BUMBLEBEE_HOME_INSIDE_CONTAINER=[$BUMBLEBEE_HOME_INSIDE_CONTAINER]] : "
echo " --------------------------------------------------------------------------------"
ls -allh $BUMBLEBEE_HOME_INSIDE_CONTAINER
echo " --------------------------------------------------------------------------------"

echo " --------------------------------------------------------------------------------"
echo " --------------------------------------------------------------------------------"
echo " dans [build-n-start.sh], juste avant git clone "
echo " --------------------------------------------------------------------------------"
echo " VERIFICATION DU CONTENU DE [BUMBLEBEE_WORKSPACE_INSIDE_CONTAINER=[$BUMBLEBEE_WORKSPACE_INSIDE_CONTAINER]] : "
echo " --------------------------------------------------------------------------------"
ls -allh $BUMBLEBEE_WORKSPACE_INSIDE_CONTAINER
echo " --------------------------------------------------------------------------------"
echo " --------------------------------------------------------------------------------"
echo " dans [build-n-start.sh] [whoami=[$(whoami)]] : "
echo " --------------------------------------------------------------------------------"

mkdir -p $BUMBLEBEE_WORKSPACE_INSIDE_CONTAINER


git clone $SSH_URI_REPO_GIT_CODE_POKUS $BUMBLEBEE_WORKSPACE_INSIDE_CONTAINER

cd $BUMBLEBEE_WORKSPACE_INSIDE_CONTAINER

# because we don't want this git repo to interfere with $GITOPS in the workpsace
rm -fr ./.git/


#
# defines from workign directory where the
# files are going to be uploaded.
#
# export POKUS_WKSP=$BUMBLEBEE_WORKSPACE_INSIDE_CONTAINER/esptravail
# export POKUS_UPLOADS=$BUMBLEBEE_WORKSPACE_INSIDE_CONTAINER/uploads
# export POKUS_GITOPS=$BUMBLEBEE_WORKSPACE_INSIDE_CONTAINER/pokus

git clone $SSH_URI_REPO_GIT_CODE_HUGO $POKUS_GITOPS

npm install -g tsoa

npm install
tsoa routes
npm run build



if [ $? -eq 0 ]; then
  echo "Successfully built [https://pokus.$NOM_DOMAINE_SITEWEB]"
else
  echo "Bumblebee encoutered a problem Hugo building [https://pokus.$NOM_DOMAINE_SITEWEB] "
  exit 2
fi;
npm run server

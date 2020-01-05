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

git clone $SSH_URI_REPO_GIT_CODE_HUGO $BUMBLEBEE_WORKSPACE_INSIDE_CONTAINER

cd $BUMBLEBEE_WORKSPACE_INSIDE_CONTAINER

export URI_REPO=https://github.com/Jean-Baptiste-Lasselle/fwdkatacoda.git
export WORKDIR=$(pwd)/pokus
mkdir $WORKDIR
git clone $URI_REPO $WORKDIR
cd $WORKDIR
# because we don't want this git repo to interfere with $GITOPS in the workpsace
rm -fr ./.git/

#
# defines from workign directory where the
# files are going to be uploaded.
#
export POKUS_WKSP=$(pwd)/workspace
export POKUS_UPLOADS=$POKUS_WKSP/uploads
export POKUS_GITOPS=$POKUS_WKSP/pokus
mkdir -p $POKUS_WKSP
mkdir -p $POKUS_UPLOADS
mkdir -p $POKUS_GITOPS

# mkdir -p ~/.ssh
# ssh-keygen -t rsa -b 4096
# cat ~/.ssh/id_rsa.pub
export GITOPS_REPO=https://github.com/Jean-Baptiste-Lasselle/hugoify.git
# export GITOPS_REPO=git@github.com:Jean-Baptiste-Lasselle/hugoify.git

git clone $GITOPS_REPO $POKUS_GITOPS

npm install
tsoa routes
npm run build
npm run server


if [ $? -eq 0 ]; then
  echo "Successfully built [https://pokus.$NOM_DOMAINE_SITEWEB]"
else
  echo "Bumblebee encoutered a problem Hugo building [https://pokus.$NOM_DOMAINE_SITEWEB] "
  exit 2
fi;

#
# On pousse le commit initial sur le master, puis chaque modfication ultérieure doit respecter le git flow.
# On protègera donc les branches par rapport aux merges, dans gitlab (ou github, ou un git service provider).
#
export COMMIT_MESSAGE="Livraison du build hugo du site internet [https://$NOM_DOMAINE_SITEWEB], par [$(hostname)] "


echo "# +++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Juste avant le [git commit n push]"
echo "# +++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo " Contenu du répertoire contenant le résultat du build hugo [$BUMBLEBEE_WORKSPACE_INSIDE_CONTAINER/public/] : "
ls -allh $BUMBLEBEE_WORKSPACE_INSIDE_CONTAINER/public/
echo "# +++++++++++++++++++++++++++++++++++++++++++++++++++++"

git add --all && git commit -m "$COMMIT_MESSAGE" && git push -u origin master

if [ $? -eq 0 ]; then
  echo "Successfully delivered hugo build result of [https://$NOM_DOMAINE_SITEWEB] to [$SSH_URI_TO_PIPELINE_DNA]"
else
  echo "Bumblebee encoutered a problem pushing result of hugo build of [https://$NOM_DOMAINE_SITEWEB] to [$SSH_URI_TO_PIPELINE_DNA]"
  exit 2
fi;

git tag "$(hostname)" -m "build hugo project"
git push --tags



# cd public
# parcel ./**/*.html
# cd ..

echo " "
echo " # --- ############################################### --- "
echo "   You can now see at [$PIPELINE_GIT_SERVICE_PROVIDER_HOSTNAME]  the  commands to"
echo "   static site generated by hugo for your site at [$SSH_URI_TO_PIPELINE_DNA]"
echo " # --- ############################################### --- "
echo " "

#!/bin/bash


# Le git service provider utilisé pour le pipeline
# export PIPELINE_GIT_SERVICE_PROVIDER_HOSTNAME=${PIPELINE_GIT_SERVICE_PROVIDER_HOSTNAME:-gitlab.com}
# La paire de clef générée pour Bumblebee est ajoutée par Bumblebee, au compte de
# l'utilisateur [PIPELINE_GIT_SERVICE_PROVIDER_HOSTNAME] (par exemple [Gitlab.com])
# que le robot Bumblebee peut utiliser pour opérer.
# Pour ce faire, Bumblebee utilise :
#
# ++++ la Gitlab API v4, si [PIPELINE_GIT_SERVICE_PROVIDER_HOSTNAME] est une instance [Gitlab EE/CE] ,
#
# ++++ la Github API, si [PIPELINE_GIT_SERVICE_PROVIDER_HOSTNAME] est [Github.com] ,
#
# ++++ la Gitlab API v4, si [PIPELINE_GIT_SERVICE_PROVIDER_HOSTNAME] est une instance [Gitea] ,
#

# export PIPELINE_GIT_SERVICE_ACCESS_TOKEN=LJNxjxyHQqNvbZQzcZsS
#
# export BUMBLEBEE_ID=cerno-alpha
# export BUMBLEBEE_SECRET_VAULT_OUTSIDE_CONTAINER=$(pwd)/.robots/$BUMBLEBEE_ID/.secrets

#
# Les chemins des clefs générées : calulés et déclarés dans [.pipeline.run.env]
#
# export BUMBLEBEE_SSH_PRIVATE_KEY_FULLPATH=$BUMBLEBEE_SECRET_VAULT_OUTSIDE_CONTAINER/.ssh/pegasus-bot-${BUMBLEBEE_ID}-bumblebeekey_rsa
# export BUMBLEBEE_SSH_PRIVATE_KEY_FILENAME=$(echo $BUMBLEBEE_SSH_PRIVATE_KEY_FULLPATH  | awk -F '/' '{print $NF}')

# export BUMBLEBEE_SSH_PUBLIC_KEY_FULLPATH=$BUMBLEBEE_SECRET_VAULT_OUTSIDE_CONTAINER/.ssh/pegasus-bot-${BUMBLEBEE_ID}-bumblebeekey_rsa.pub
# export BUMBLEBEE_SSH_PUBLIC_KEY_FILENAME=$(echo $BUMBLEBEE_SSH_PRIVATE_KEY_FULLPATH  | awk -F '/' '{print $NF}')

#
# On génère la paire de clefs SSH utilisée par le "bumblebee robot" (bumblebee est une famille de robot, pas un robot particulier)
#


#
# GENERATION DE LA PAIRE DE CLEFS SSH UTILISEE PAR BUMBLEBEE :
#
# => pour faire des git clone commit and puss vers le repo SSH_URI_REPO_GIT_CODE_HUGO
#
# Il faut donc générer cette paire de clefs, puis utiliser une clef (pas celle de BUMBLEBEE, la mienne en tant qu'administrateur de ma propre machine, pour installer cette clef )
#

mkdir -p $BUMBLEBEE_SECRET_VAULT_OUTSIDE_CONTAINER/.ssh
echo " --------------------------------------- "
echo " POINT DEBUG - contenu de [pwd=[$(pwd)]] : "
echo " --------------------------------------- "
ls -allh .
echo " --------------------------------------- "

./generer-paire-de-clefs-robot.sh $BUMBLEBEE_SECRET_VAULT_OUTSIDE_CONTAINER/.ssh $BUMBLEBEE_ID

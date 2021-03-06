#!/bin/bash



#
# Le but de ce script, est de remplacer la logique des robots qui sera implémentée plus tard.
#
# Après ce script, on aura la paire de clefs disponible dans le répertoire spécicifié en entréé
#



export WHERE_TO_CREATE_RSA_KEY_PAIR=$1
export ROBOTS_ID=$2

function Usage () {
  echo " "
  echo "The [$0] script should be used with two mandatory arguments : "
  echo " [$0] \$FOLDER_WHERE_TO_CREATE_RSA_KEY_PAIR \$ROBOTS_ID"
  echo " "
  echo " Where : "
  echo "    FOLDER_WHERE_TO_CREATE_RSA_KEY_PAIR    is an existing folder path "
  echo "    ROBOTS_ID is the bumblebee id of an existing Robot"
  echo " "
  echo " Arguments You provided to [$0]: "
  echo " "
  echo "    FOLDER_WHERE_TO_CREATE_RSA_KEY_PAIR    WHERE_TO_CREATE_RSA_KEY_PAIR=[$WHERE_TO_CREATE_RSA_KEY_PAIR] "
  echo "    ROBOTS_ID                              ROBOTS_ID=[$ROBOTS_ID] "
  echo " "
}

if ! [ -d "$WHERE_TO_CREATE_RSA_KEY_PAIR" ]; then
  Usage && exit 1
fi;

if [ "x$WHERE_TO_CREATE_RSA_KEY_PAIR" == "x" ]; then
  Usage && exit 1
fi;

if [ "x$ROBOTS_ID" == "x" ]; then
  Usage && exit 1
fi;

export PRIVATE_KEY_FULLPATH=$WHERE_TO_CREATE_RSA_KEY_PAIR/pegasus-bot-${ROBOTS_ID}-bumblebeekey_rsa


export PEGASUS_DEFAULT_PRIVATE_KEY_PASSPHRASE="Etre ou ne pas etre, telle est la question"
# - putain mais ooui pour gitlab.com, la clef enregistrée ne DOIT PAS avoir de passphrase, sinon l'authentification foire !!!
# ou alors il faut tester comment faire la passphrase en mode command line silenceieux
export PEGASUS_DEFAULT_PRIVATE_KEY_PASSPHRASE=""
# putain ouais c'est énorme j'ai bien testé que la [passphrase] fait échouer l'auth. [gitlab.com]
#
export LE_COMMENTAIRE_DE_CLEF="[$ROBOTS_ID]-bumblebee@[workstation]-$(hostname)"
export LE_COMMENTAIRE_DE_CLEF="[$ROBOTS_ID]-bumblebee@[$PIPELINE_EXECUTION_ID]"

ssh-keygen -C $LE_COMMENTAIRE_DE_CLEF -t rsa -b 4096 -f $PRIVATE_KEY_FULLPATH -q -P "$PEGASUS_DEFAULT_PRIVATE_KEY_PASSPHRASE"

ls -allh $WHERE_TO_CREATE_RSA_KEY_PAIR

sleep 3s




# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
# $$$$$$$$$$  AJOUT DE LA CLEF SSH AUX CLEFS SSH
# $$$$$$$$$$  DU COMPTE UTILISATEUR ROBOT SUR GITLAB.COM
# $$$$$$$$$$  SE FAIT AVEC L'USAGE DE
# $$$$$$$$$$  l'ACCESS TOKEN [GITLAB API v4]
# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

sudo apt-get install -y dialog

export QUESTION="Connect to your gitlab [$PIPELINE_GIT_SERVICE_PROVIDER_HOSTNAME] account, \n In the Settings Menu for your gitlab [$PIPELINE_GIT_SERVICE_PROVIDER_HOSTNAME] user, Search for the \"Personal Access Token\" Menu, \n from which you will be able to create a new token for your bumblebee robot. \n What's the value of your token? \n (Copy / paste the token value and press Enter Key) "

#
# Pas de valeur par défaut,le [2>] estlà pour faire la redirection de canal de sortie du processs (synchrone) de la commande [dialog]
#
dialog --inputbox "$QUESTION" 15 50 2> ./gitlab.access.token.reponses.pegasus


# export PIPELINE_GIT_SERVICE_PROVIDER_HOSTNAME=gitlab.com
export GITLAB_ACCESS_TOKEN=$(cat ./gitlab.access.token.reponses.pegasus)
# Security (don't leave any secret on the file system, ne it in a container or a VM):
rm ./gitlab.access.token.reponses.pegasus

export ACCESS_TOKEN=$GITLAB_ACCESS_TOKEN

# export ACCESS_TOKEN=qPb4xYwfiExRu-uGk9Bv

echo "$PEGASUS_PSONE $PEGASUS_OPS_ALIAS Liste des clefs SSH avant ajout de la clef pegasus : "
ls -allh $WHERE_TO_CREATE_RSA_KEY_PAIR

curl --header "PRIVATE-TOKEN: $ACCESS_TOKEN" -X GET "https://$PIPELINE_GIT_SERVICE_PROVIDER_HOSTNAME/api/v4/user/keys" | jq .


# -- Now Adding Pegasus SSH Key to the User, using the TOKEN
# export THAS_THE_PUB_KEY=$(cat ~/.ssh/id_rsa.pub)
export THAS_THE_PUB_KEY=$(cat "$PRIVATE_KEY_FULLPATH".pub )

echo "$PEGASUS_PSONE $PEGASUS_OPS_ALIAS Ajout de la clef SSH avant ajout de la clef pegasus : "
export PAYLOAD="{ \"title\": \"clef_SSH_PEGASUS${RANDOM}\", \"key\": \"$THAS_THE_PUB_KEY\" }"
curl -H "Content-Type: application/json" -H "PRIVATE-TOKEN: $ACCESS_TOKEN" -X POST --data "$PAYLOAD" "https://$PIPELINE_GIT_SERVICE_PROVIDER_HOSTNAME/api/v4/user/keys" | jq .






echo "$PEGASUS_PSONE $PEGASUS_OPS_ALIAS Liste des clefs SSH APRES ajout de la clef pegasus : "
curl --header "PRIVATE-TOKEN: $ACCESS_TOKEN" -X GET "https://$PIPELINE_GIT_SERVICE_PROVIDER_HOSTNAME/api/v4/user/keys" | jq .


# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
# $$$$$$$$$$  AJOUT DE LA CLEF SSH AUX CLEFS SSH
# $$$$$$$$$$  DU COMPTE UTILISATEUR ROBOT SUR GITHUB.COM
# $$$$$$$$$$  SE FAIT AVEC L'USAGE DE
# $$$$$$$$$$  l'ACCESS TOKEN [GITHUB API v3]
# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
#
# https://developer.github.com/v3/users/keys/#list-your-public-keys
# https://stackoverflow.com/questions/16672507/how-to-add-ssh-keys-via-githubs-v3-api
# https://developer.github.com/v3/#authentication
# https://developer.github.com/apps/building-oauth-apps/
# --------------------------------------------------
# cf. documentation/github/README.md#authentication
# --------------------------------------------------
# --------------------------------------------------
# -- Auth to Github API using TOKENS
# --
# curl -H "Authorization: token OAUTH-TOKEN" https://api.github.com
# --
export GITHUB_PERSONAL_ACCESS_TOKEN=38b906742101991cdbf1e61f7b59df670230b772
export GITHUB_PERSONAL_ACCESS_TOKEN=38b906742101991cdbf1e61f7b59df670230b772
export GITHUB_PERSONAL_ACCESS_TOKEN=9db3248a125828064ce4dae8886da026fcb8f59a

# - Just checks if Github recognizes me :
curl -H "Authorization: token $GITHUB_PERSONAL_ACCESS_TOKEN" https://api.github.com/user
# - Now listing current public SSH Keys :
curl -H "Authorization: token $GITHUB_PERSONAL_ACCESS_TOKEN" https://api.github.com/user/keys  | jq '.[] .title'


# - Now adding desired public key to my Github user account for my bumblebee robot

export PUBLIC_SSH_KEY_VALUE_TO_ADD=$(cat $BUMBLEBEE_SSH_PUBLIC_KEY_FULLPATH)

echo " "
echo " ------------------------------------------------------------------------------------ "
echo "    vérification , avant appel [Github API v3] de PUBLIC_SSH_KEY_VALUE_TO_ADD :  "
echo " ------------------------------------------------------------------------------------ "
echo "       [$PUBLIC_SSH_KEY_VALUE_TO_ADD] "
echo " ------------------------------------------------------------------------------------ "
echo " "



touch github.api-payload.json
rm github.api-payload.json
echo "{" >> github.api-payload.json
echo "  \"title\": \"bumblebee@pokusio.pipeline\"," >> github.api-payload.json
echo "  \"key\": \"$(cat $BUMBLEBEE_SSH_PUBLIC_KEY_FULLPATH)\"" >> github.api-payload.json
echo "}" >> github.api-payload.json

touch ./returned-json.json
rm ./returned-json.json
curl -X POST -H "Authorization: token $GITHUB_PERSONAL_ACCESS_TOKEN" --data @github.api-payload.json https://api.github.com/user/keys >> returned-json.json


# export ADDED_SSH_KEY_GITHUB_API_V3_KEY_ID=39871898
export ADDED_SSH_KEY_GITHUB_API_V3_KEY_ID=$(cat returned-json.json | jq '.id')

# - Now displaying the newly added public SSH Key :
echo "Successfulluy Added SSH key : "
curl -H "Authorization: token $GITHUB_PERSONAL_ACCESS_TOKEN" https://api.github.com/user/keys/${ADDED_SSH_KEY_GITHUB_API_V3_KEY_ID}

# - Finally listing again all current public SSH Keys :
curl -H "Authorization: token $GITHUB_PERSONAL_ACCESS_TOKEN" https://api.github.com/user/keys  | jq '.[] .title'

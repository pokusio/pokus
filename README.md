# Pokus

https://pok-us.io/ _(domain name bought on 22/02/2020 )_

[![Docker Repository on Quay](https://quay.io/repository/pok-us-io/pokus_api_oci_build/status "Docker Repository on Quay")](https://quay.io/repository/pok-us-io/pokus_api_oci_build)



* J'ai acheté le nom de domaine https://pok-us-io/ pour le projet `pokus`, et notamment sa partie `pokus'portus`
* Organisation `github` : https://github.com/pokus-io

The distributed, scalable Content Manager for hugo.

`TypeScript` / `TSOA` based microservice app.

# IAAC

* If I do a standard IAAC initialization :

```bash
export DEV_HOME=~/pokus.dev
export URI_GIT=git@gitlab.com:second-bureau/pegasus/pokus/pokus.git
export FEATURE_ALIAS='git_tree_endpoint'

git clone ${URI_GIT} ${DEV_HOME}
cd ${DEV_HOME}

git flow init --defaults

git checkout "feature/${FEATURE_ALIAS}"

export COMMIT_MESSAGE="feat(${FEATURE_ALIAS}): adding iaac cycle to [./README.md]"

git add --all && git commit -m "${COMMIT_MESSAGE}" && git push -u origin HEAD

atom .

```

* If I use the `ìnitializeIAAC` bash function of mine :

```bash
export WORK_FOLDER=~/pokus.dev
export SSH_URI_TO_THIS_REPO=git@gitlab.com:second-bureau/pegasus/pokus/pokus.git

export COMMIT_MESSAGE=""
export COMMIT_MESSAGE="$COMMIT_MESSAGE Reprise du travail sur [$SSH_URI_TO_THIS_REPO]"

initializeIAAC $SSH_URI_TO_THIS_REPO $WORK_FOLDER

atom .
# git add --all && git commit -m "$COMMIT_MESSAGE" && git push -u origin master

```

## Brouillon: build n run

_super tuto angular rest api JWT auth https://www.toptal.com/angular/angular-6-jwt-authentication_


### Build, run, n test

* Dans un environnement :

```bash
# --
jbl@poste-devops-jbl-16gbram:~/pokus.dev$ node --version
v14.4.0
jbl@poste-devops-jbl-16gbram:~/pokus.dev$ npm --version
6.14.5
jbl@poste-devops-jbl-16gbram:~/pokus.dev$ yarn --version
1.22.4
jbl@poste-devops-jbl-16gbram:~/pokus.dev$ npm list --depth 0 -g tsoa
/usr/lib
└── tsoa@3.2.1

jbl@poste-devops-jbl-16gbram:~/pokus.dev$ npm list --depth 1 -g tsoa
/usr/lib
└── tsoa@3.2.1

jbl@poste-devops-jbl-16gbram:~/pokus.dev$ npm list --depth 0 -g multer
/usr/lib
└── multer@1.4.2

jbl@poste-devops-jbl-16gbram:~/pokus.dev$ npm list --depth 1 -g multer
/usr/lib
└── multer@1.4.2

jbl@poste-devops-jbl-16gbram:~/pokus.dev$

```

* exécuter :

```bash
export URI_POKUS_REPO=git@gitlab.com:second-bureau/pegasus/pokus/pokus.git
export WORKDIR=$(pwd)/pokus-test
git clone $URI_POKUS_REPO $WORKDIR
cd $WORKDIR
# because we don't want this git repo to interfere with $GITOPS in the workpsace
rm -fr ./.git/

#
# defines from working directory where the
# files are going to be uploaded.
#
export MULTER_VERSION='1.4.2'
export TSOA_VERSION='3.2.1'
export POKUS_WKSP=$(pwd)/pokus.workspace
export POKUS_UPLOADS=${POKUS_WKSP}/uploads
export POKUS_GITOPS=${POKUS_WKSP}/pokus
mkdir -p $POKUS_UPLOADS
mkdir -p $POKUS_GITOPS
# mkdir -p ~/.ssh
# ssh-keygen -t rsa -b 4096
# cat ~/.ssh/id_rsa.pub
export GITOPS_REPO=https://github.com/Jean-Baptiste-Lasselle/hugoify.git
# export GITOPS_REPO=git@github.com:Jean-Baptiste-Lasselle/hugoify.git
git clone ${GITOPS_REPO} ${POKUS_GITOPS}
npm i -g tsoa@${TSOA_VERSION} multer@${MULTER_VERSION}
npm install
tsoa routes -c tsoa.json
npm run build
npm run server
```

* Suite au démarrage du serveur, on aura, dans une autre session shell, une réponse API en requêtant en `GET` :

```bash
#
export POKUS_API_HOSTNAME="$(hostname)"
export POKUS_API_HOSTNAME=localhost
export POKUS_API_PORT_NO=3000
export POKUS_UPLOADS=$(pwd)/pokus_uploads
export POKUS_GITOPS=$(pwd)/pokus_gitops

curl -X GET http://$POKUS_API_HOSTNAME:$POKUS_API_PORT_NO/api/v1 | jq .
curl -X GET http://$POKUS_API_HOSTNAME:$POKUS_API_PORT_NO/api/v1/msg | jq .

```

* Suite au démarrage du serveur, on aura, dans une autre session shell, une réponse API en requêtant en GET :

```bash
# On [Katacoda.com] / [NodeJS] playground :
export POKUS_API_HOSTNAME=2886795275-3000-elsy06.environments.katacoda.com
export POKUS_API_PORT_NO=80
# Locally
export POKUS_API_HOSTNAME=localhost
export POKUS_API_PORT_NO=3000

export POKUS_UPLOADS=$(pwd)/pokus_uploads
export POKUS_GITOPS=$(pwd)/pokus_gitops

#
# Invocation du endpoint /files/uploadFile
#

mkdir -p ./ptitestespace
echo 'ceci est un magnifique fichier que j ai edité' > ./ptitestespace/autrefichier.pokus

export CHEMIN_FICHIER_DS_GIT_REPO=exemple/rep1/rep2/autrefichier.pokus
export CHEMIN_LOCAL_FICHIER=./ptitestespace/autrefichier.pokus

curl -L -X POST -F "fichierSousEdition=@\"$CHEMIN_LOCAL_FICHIER\""  -F "cheminRepoGitFichierSousEdition=\"$CHEMIN_FICHIER_DS_GIT_REPO\"" http://$POKUS_API_HOSTNAME:$POKUS_API_PORT_NO/api/v1/files/uploadFile | jq .

#
# Invocation GET du endpoint [/]
#
curl -L -X GET http://$POKUS_API_HOSTNAME:$POKUS_API_PORT_NO/api/v1 | jq .

#
# Invocation GET du endpoint [/msg]
#
curl -L -X GET http://$POKUS_API_HOSTNAME:$POKUS_API_PORT_NO/api/v1/msg | jq .
```

* Invocation testée du endpoint `api/v1/files/uploadFile` Ici, en ajoutant le paramètre de formulaire _http multipart_ `cheminRepoGitFichierSousEdition`, ait pour valeur le chemin du sous-répertoire de `workspace/pokus`, dans lequel on veut enregistrer le fichier sur le serveur :

```bash
curl -L -X POST -F 'fichierSousEdition=@"./ptitestespace/autrefichier.pokus"'  -F 'cheminRepoGitFichierSousEdition="./ptitestespace/autrefichier.pokus"' http://$POKUS_API_HOSTNAME:$POKUS_API_PORT_NO/api/v1/files/uploadFile
# pour l'instant, les fichiers sont tous enregistrés dansle sous-répertoire 'workspace/pokus/subfolder1'
```

### Running Containerized

TOP TODO :

* Faire le endpoint qui va chercher un fichier, lire dedans, et renvoyer le contenu texte au client `Angular` .
* Pour lire ecrire ds fichiers en `TypeScript`: https://stackoverflow.com/questions/33643107/read-and-write-a-text-file-in-typescript


## Install

To install the application, do the following after cloning the repository:
```bash
$ npm install
```

## Build and Run
To build the application:
```bash
$ npm run build
```

And to run the server:
```bash
$ npm run server
```

## Codestyle
To check the codestyle (lint), do the following:
```bash
$ npm run lint
```

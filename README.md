# Pokus

The distributed, scalable Content Manager for hugo.

`TypeScript` / `TSOA` based microservice app.

# IAAC

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

### Build : private infra

```bash

npm install

tsoa routes
npm run build
npm run server
```
* Suite au démarrage du serveur, on aura une réponse API en requêtant en GET :

```bash
#
export POKUS_API_HOSTNAME=poste-devops-typique
export POKUS_API_PORT_NO=3000

curl -X GET http://$POKUS_API_HOSTNAME:$POKUS_API_PORT_NO/api/v1 | jq .
curl -X GET http://$POKUS_API_HOSTNAME:$POKUS_API_PORT_NO/api/v1/msg | jq .

```
### Build : Sur [Katacoda.com] / [NodeJS] playground

```bash
export URI_REPO=https://github.com/Jean-Baptiste-Lasselle/fwdkatacoda.git
export WORKDIR=$(pwd)/pokus
mkdir $WORKDIR
git clone $URI_REPO $WORKDIR
cd $WORKDIR
# because we don't want this git repo to interfere with $GITOPS in the workpsace
rm -fr ./.git/
npm install

tsoa routes
npm run build
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

git clone https://github.com/Jean-Baptiste-Lasselle/hugoify.git $POKUS_GITOPS

npm run server

```
* Suite au démarrage du serveur, on aura une réponse API en requêtant en GET :

```bash
# Sur [Katacoda.com] / [NodeJS] playground :
export POKUS_API_HOSTNAME=2886795275-3000-elsy06.environments.katacoda.com
export POKUS_API_PORT_NO=80

#
# Invocation du endpoint /files/uploadFile
#

mkdir -p ./ptitestespace
echo 'ceci est un magnifique fichier que j ai edité' > ./ptitestespace/autrefichier.pokus
curl -L -X POST -F 'fichierSousEdition=@"./ptitestespace/autrefichier.pokus"'  -F 'cheminFichierSousEdition="ptitestespace/autrefichier.pokus"' http://$POKUS_API_HOSTNAME:$POKUS_API_PORT_NO/api/v1/files/uploadFile | jq .

#
# Invocation du endpoint /
#
curl -L -X GET http://$POKUS_API_HOSTNAME:$POKUS_API_PORT_NO/api/v1 | jq .

#
# Invocation du endpoint /msg
curl -L -X GET http://$POKUS_API_HOSTNAME:$POKUS_API_PORT_NO/api/v1/msg | jq .

```
* Invocation testée du endpoint `api/v1/files/uploadFile`Ici, en ajoutant le paramètre de formulaire _http multipart_ `cheminFichierSousEdition`, ait pour valeur le chemin du sous-répertoire de `workspace/pokus`, dans lequel on veut enregistrer le fichier sur le serveur :

```bash
curl -L -X POST -F 'fichierSousEdition=@"./ptitestespace/autrefichier.pokus"'  -F 'cheminFichierSousEdition="./ptitestespace/"' http://$POKUS_API_HOSTNAME:$POKUS_API_PORT_NO/api/v1/files/uploadFile
# pour l'instant, les fichiers sont tous enregistrés dansle sous-répertoire 'workspace/pokus/subfolder1'
```



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

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

### Build

```bash

npm install

tsoa routes
npm run build
npm run server
```
* Suite au démarrage du serveur, on aura une réponse API en requêtant en GET :

```bash
# Sur [Katacoda.com] / [NodeJS] playground :
export POKUS_API_HOSTNAME=2886795275-3000-elsy06.environments.katacoda.com
export POKUS_API_PORT_NO=80
curl -L -X GET http://$POKUS_API_HOSTNAME:$POKUS_API_PORT_NO/api/v1 | jq .
curl -L -X GET http://$POKUS_API_HOSTNAME:$POKUS_API_PORT_NO/api/v1/msg | jq .

# Sur un envrionnement interne :
export POKUS_API_HOSTNAME=poste-devops-typique
export POKUS_API_PORT_NO=3000

curl -X GET http://$POKUS_API_HOSTNAME:$POKUS_API_PORT_NO/api/v1 | jq .
curl -X GET http://$POKUS_API_HOSTNAME:$POKUS_API_PORT_NO/api/v1/msg | jq .

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

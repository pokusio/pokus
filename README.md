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
# Environnement de Build Global
#
npm install -g @types/node
npm install -g tsoa
# https://palantir.github.io/tslint/
npm install -g tslint

#
npm init --yes
npm install --save-dev tsoa
npm install --save-dev @types/node
# npm install --save-dev tslint

tsoa routes
npm run build
npm run server

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

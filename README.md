# Pokus

The distributed Content Manager for hugo.

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
FROM node:8.16.2-stretch
# FROM docker.pegasusio.io/pokus/pokus:0.0.1

LABEL product="pokus"
LABEL maintainer="Jean-Baptiste-Lasselle <jean.baptiste.lasselle.pegasus@gmail.com>"
LABEL author="Jean-Baptiste-Lasselle <jean.baptiste.lasselle.pegasus@gmail.com>"
LABEL build="0.0.0.0.0.0.0.0"
LABEL commitid="0.0.0.0.0.0.0.0"
# *+DIAGNOSTIC+*  COPY calculer-jour-francais.sh .
# *+DIAGNOSTIC+*  COPY container-french-mood.sh .
# RUN apt-get update -y && chmod +x ./calculer-jour-francais.sh && ./calculer-jour-francais.sh && pwd
# RUN apt-get update -y
# *+DIAGNOSTIC+*  RUN chmod +x ./calculer-jour-francais.sh
# *+DIAGNOSTIC+*  RUN ./calculer-jour-francais.sh
# *+DIAGNOSTIC+*  RUN pwd
# *+DIAGNOSTIC+*  RUN ls -allh .
# *+DIAGNOSTIC+*  LABEL date="$(cat bellinda) $(date +%F) $(date +%T) $(date +%Z)"
LABEL daymood="firefox https://www.youtube.com/watch?v=fBM3nb-3iFs"

# AUTHOR Jean-Baptiste-lasselle


# ------------------------
# ---------- HUGO ENV.
# ------------------------

# ---- HUGO OPS ENVIRONMENT

ARG NOM_DOMAINE_SITEWEB
ENV NOM_DOMAINE_SITEWEB=$NOM_DOMAINE_SITEWEB


# ------------------------
# ---------- POKUS ENV.
# ------------------------
ARG SSH_URI_REPO_GIT_CODE_HUGO
ENV SSH_URI_REPO_GIT_CODE_HUGO=$SSH_URI_REPO_GIT_CODE_HUGO

ARG SSH_URI_REPO_GIT_CODE_POKUS
ENV SSH_URI_REPO_GIT_CODE_POKUS=$SSH_URI_REPO_GIT_CODE_POKUS

ARG POKUS_WKSP=$POKUS_WKSP
ENV POKUS_WKSP=$POKUS_WKSP

ARG POKUS_UPLOADS=$POKUS_WKSP
ENV POKUS_UPLOADS=$POKUS_UPLOADS

ARG POKUS_GITOPS=$POKUS_WKSP
ENV POKUS_GITOPS=$POKUS_GITOPS


# ---
# IAAC cycle Parameters
# ---

ARG PIPELINE_GIT_SERVICE_PROVIDER_HOSTNAME=$PIPELINE_GIT_SERVICE_PROVIDER_HOSTNAME
ENV PIPELINE_GIT_SERVICE_PROVIDER_HOSTNAME=$PIPELINE_GIT_SERVICE_PROVIDER_HOSTNAME

# ARG GIT_SSH_COMMAND=$GIT_SSH_COMMAND
ENV BUMBLEBEE_GIT_SSH_COMMAND=$BUMBLEBEE_GIT_SSH_COMMAND
ENV GIT_SSH_COMMAND=$BUMBLEBEE_GIT_SSH_COMMAND

# ARG BUMBLEBEE_SSH_PRIVATE_KEY_FILENAME=$BUMBLEBEE_SSH_PRIVATE_KEY_FILENAME
ENV BUMBLEBEE_SSH_PRIVATE_KEY_FILENAME=$BUMBLEBEE_SSH_PRIVATE_KEY_FILENAME

ARG TAG_MESSAGE="Commit par Pokus [$(whoami)] at [$(date)]."
ENV TAG_MESSAGE=$TAG_MESSAGE


#
# IDE_HOME_INSIDE_CONTAINER => BUMBLEBEE_HOME_INSIDE_CONTAINER
# IDE_WORKSPACE_INSIDE_CONTAINER => BUMBLEBEE_WORKSPACE_INSIDE_CONTAINER

ARG BUMBLEBEE_HOME_INSIDE_CONTAINER=$BUMBLEBEE_HOME_INSIDE_CONTAINER
ENV BUMBLEBEE_HOME_INSIDE_CONTAINER=$BUMBLEBEE_HOME_INSIDE_CONTAINER

ARG BUMBLEBEE_WORKSPACE_INSIDE_CONTAINER=$BUMBLEBEE_HOME_INSIDE_CONTAINER/workspace
ENV BUMBLEBEE_WORKSPACE_INSIDE_CONTAINER=$BUMBLEBEE_HOME_INSIDE_CONTAINER/workspace

#
# --- les variables liées avec le processus précédent : l'initialisationdu projet [Pegasus] (Pegasus Git Service Providers).
#


USER root



RUN apt-get update -y && apt-get install -y git git-flow curl wget


RUN mkdir -p $BUMBLEBEE_HOME_INSIDE_CONTAINER
RUN echo "valeur de BUMBLEBEE_WORKSPACE_INSIDE_CONTAINER=[${BUMBLEBEE_WORKSPACE_INSIDE_CONTAINER}]"
RUN mkdir -p $BUMBLEBEE_WORKSPACE_INSIDE_CONTAINER
RUN mkdir -p $POKUS_WKSP
RUN mkdir -p $POKUS_UPLOADS
RUN mkdir -p $POKUS_GITOPS
COPY build-n-start.sh $BUMBLEBEE_HOME_INSIDE_CONTAINER
COPY init-iaac.sh $BUMBLEBEE_HOME_INSIDE_CONTAINER
# COPY pipeline-step.healthcheck.sh $BUMBLEBEE_HOME_INSIDE_CONTAINER

RUN chown -R node:node $BUMBLEBEE_HOME_INSIDE_CONTAINER
RUN chmod a+x $BUMBLEBEE_HOME_INSIDE_CONTAINER/*.sh


WORKDIR BUMBLEBEE_HOME_INSIDE_CONTAINER_JINJA2_VAR

# HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD [ "BUMBLEBEE_HOME_INSIDE_CONTAINER_JINJA2_VAR/pipeline-step.healthcheck.sh" ]

ENTRYPOINT ["BUMBLEBEE_HOME_INSIDE_CONTAINER_JINJA2_VAR/build-n-start.sh"]

#
# I want bash inside, not just /bin/sh, because
# though this container is not meant for an interactive use
# I still want to have a possible fallback access
CMD ["/bin/bash"]

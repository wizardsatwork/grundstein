#!/bin/bash

source ./ENV.sh
source ../tasks.sh

function build() {
  echo "building: $CONTAINER_NAME"

  docker pull gitlab/gitlab-ce:latest

  echo "build finished"
}

function run-orig() {
  remove

  echo "run $CONTAINER_NAME"

  docker run --detach \
    --detach \
    --publish $CONTAINER_PORT_443:$HOST_PORT_443 \
    --publish $CONTAINER_PORT_80:$HOST_PORT_80 \
    --publish $CONTAINER_PORT_22:$HOST_PORT_22 \
    --env 'GITLAB_SSH_PORT=$HOST_PORT_22'\
    --env 'GITLAB_PORT=$HOST_PORT_80' \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    --name $CONTAINER_NAME \
    --restart always \
    --volume config:/etc/gitlab \
    --volume logs:/var/log/gitlab \
    --volume data:/var/opt/gitlab \
    gitlab/gitlab-ce:latest

  echo "started docker container"
}

function run() {
  remove

  echo "starting container $CONTAINER_NAME"

  docker run \
    --hostname $HOSTNAME \
    --name $CONTAINER_NAME \
    --detach \
    --link magic-postgres:postgresql \
    --link magic-redis:redisio \
    --publish $HOST_PORT_22:$CONTAINER_PORT_22 \
    --publish $HOST_PORT_80:$CONTAINER_PORT_80 \
    --env "GITLAB_HOST=$HOSTNAME" \
    --env "GITLAB_PORT=$HOST_PORT_80" \
    --env "GITLAB_SSH_PORT=$HOST_PORT_22" \
    --env "DB_NAME=$GITLAB_DB_NAME" \
    --env "DB_USER=$GITLAB_DB_USER" \
    --env "DB_PASS=$GITLAB_DB_PASS" \
    --env "GITLAB_SECRETS_DB_KEY_BASE=$GITLAB_SECRETS_DB_KEY_BASE" \
    --volume $PWD/data:/home/git/data \
    sameersbn/gitlab:8.4.1
}

function help() {
  echo "${CONTAINER_NAME}"
  echo "Usage:"
  echo ""
  echo './cli.sh $command'
  echo ""
  echo "commands:"
  echo "run - run docker container"
  echo "remove - remove container"
  echo "update - update container"
  echo "stop - stop container"
}

if [ $1 ]
then
  function=$1
  shift
  $function $@
else
  help $@
fi

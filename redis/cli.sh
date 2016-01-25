#!/bin/bash

source ./ENV.sh

echo "container: ${CONTAINER_NAME}"

function build() {
  echo "docker building $CONTAINER_NAME"

  docker build \
    -t ${CONTAINER_NAME} \
    --build-arg="DIR=${DIR}" \
    --build-arg="USER_ID=${USER_ID}" \
    --build-arg="USER_NAME=${USER_NAME}" \
    --build-arg="PORT=${CONTAINER_PORT}" \
    --rm=true \
    . # dot!

  echo "${CONTAINER_NAME} build finished"
}

function debug() {
  echo "starting docker $CONTAINER_NAME container interactive debug session"

  docker run -i -t ${CONTAINER_NAME}
}

function rm() {
  echo "removing docker container $CONTAINER_NAME"

  docker rm -f $CONTAINER_NAME || echo 'container does not exist'
}

function run() {
  echo "starting docker container"

  rm

  docker run \
    --detach \
    --name ${CONTAINER_NAME} \
    -p ${HOST_PORT}:${CONTAINER_PORT} \
    ${CONTAINER_NAME}
}

function help() {
  echo "tasks for ${CONTAINER_NAME} container:"
  echo ""
  echo "build - build docker container"
  echo "debug - connect to container shell"
  echo "run - run container"
  echo "rm - remove container"
  echo "help - this help text"
}

if [ $1 ]
then
  function=$1
  shift
  $function $@
else
  help $@
fi


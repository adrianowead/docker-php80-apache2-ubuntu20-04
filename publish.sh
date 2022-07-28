#!/bin/bash

# ajustar o workdir
cd "$(dirname "$0")"

export DOCKR_IMG_NAME=php80-apache2
export DOCKR_HUB_REPO=adrianowead
export DOCKR_IMG_VERSION=1.0.0

# docker build
docker build -t "$DOCKR_IMG_NAME:$DOCKR_IMG_VERSION" --file=./Dockerfile .

# definir tag atual
export DOCKR_IMG_NAME_TAGGED="$DOCKR_IMG_NAME:$DOCKR_IMG_VERSION"
export DOCKR_IMG_URI="$DOCKR_HUB_REPO/$DOCKR_IMG_NAME_TAGGED"

docker tag "$DOCKR_IMG_NAME_TAGGED" "$DOCKR_IMG_URI"

# enviar para HUB
docker push "$DOCKR_IMG_URI"


# docker build
docker build -t "$DOCKR_IMG_NAME:$DOCKR_IMG_VERSION" --file=./Dockerfile .

# definir tag latest
export DOCKR_IMG_NAME_TAGGED="$DOCKR_IMG_NAME:latest"
export DOCKR_IMG_URI="$DOCKR_HUB_REPO/$DOCKR_IMG_NAME_TAGGED"

docker tag "$DOCKR_IMG_NAME_TAGGED" "$DOCKR_IMG_URI"

# enviar para HUB
docker push "$DOCKR_IMG_URI"
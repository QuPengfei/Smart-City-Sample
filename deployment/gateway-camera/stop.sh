#!/bin/bash -e

DIR=$(dirname $(readlink -f "$0"))
yml="$DIR/docker-compose.yml"

export USER_ID="$(id -u)"
export GROUP_ID="$(id -g)"
shift
. "$DIR/build.sh"
echo "Shutting down smtc gateway camera..."
docker-compose -f ${yml} down

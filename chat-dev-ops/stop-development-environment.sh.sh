#!/bin/bash
set -u
set -e

set_concourse_external_url() {
  export CONCOURSE_EXTERNAL_URL=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -1`
  echo "Setting CONCOURSE_EXTERNAL_URL to ${CONCOURSE_EXTERNAL_URL}"
}

set_concourse_external_url

echo "Stopping environment..."
docker-compose stop

#!/bin/sh

# Needed because of:
# https://github.com/felddy/foundryvtt-docker/issues/1131 
#
# based on code from:
# https://github.com/felddy/foundryvtt-docker/blob/9d1ebf8764e6dd0ee6934da3c4a3d76c31c4cee9/src/launcher.sh

CONFIG_DIR="/data/Config"
CONFIG_FILE="${CONFIG_DIR}/options.json"

mkdir -p "${CONFIG_DIR}"

if [[ "${CONTAINER_PRESERVE_CONFIG:-}" == "true" && -f "${CONFIG_FILE}" ]]; then
  :
elif [[ "${FOUNDRY_PORT:-unset}" != "unset" ]]; then
  ./set_options.js | sed s/30000/$FOUNDRY_PORT/g > "${CONFIG_FILE}"
  export CONTAINER_PRESERVE_CONFIG="true"
fi

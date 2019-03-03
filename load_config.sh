#!/bin/bash

# load configuration

CONFIG=${SCANNER_CONFIG:-"scan.config"}

function debug()
{
    echo "$(date --rfc-3339=ns) ${1}"
}

if [ ! -f "${CONFIG}" ]; then
    debug "configuration file ${CONFIG} not found"
    exit
fi

while read line; do
  if [[ "$line" =~ ^[^#]*= ]]; then
    NAME=${line%% =*}
    VALUE=${line#*= }
    export ${NAME}="${VALUE}"
  fi
done < ${CONFIG}

if [ ! -d "${DIR_SCAN}" ]; then
    debug "directory ${DIR_SCAN} not found"
    exit
fi
if [ ! -d "${DIR_OCR}" ]; then
    debug "directory ${DIR_OCR} not found"
    exit
fi

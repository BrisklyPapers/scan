#!/bin/bash

# this script creates searchable pdf files
# all pdf filesin ${DIR_SCAN} will be parsed
# the parsed pdf files will be moved from ${DIR_SCAN} to ${DIR_OCR}
# configuration has to be set in scan.config file, see example.config

# @see https://wiki.ubuntuusers.de/OCRmyPDF/

# cd into current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd ${DIR}

source load_config.sh

parse_pdf() {
    FILENAME=$1
    
    # parse pdf, add ocr layer and create new pdf file
    LC_ALL=C.UTF-8 LANG=C.UTF-8 ocrmypdf \
        -j ${OCR_JOBS} \
        -l deu+eng \
        --sidecar ${DIR_OCR}/${FILENAME}.txt \
        -d \
        -c \
        ${DIR_SCAN}/${FILENAME} ${DIR_OCR}/${FILENAME}
}

while true
do
    # loop only if pdf files exist (prevent error message)
    if [ -n "$(ls -A ${DIR_SCAN}/*.pdf 2>/dev/null)" ]; then
        for FILENAME in ${DIR_SCAN}/*.pdf; do
            debug "parse ${FILENAME}"
            BASE_FILENAME=$(basename ${FILENAME})
            parse_pdf ${BASE_FILENAME}
                        
            # do not delete source file if parsing failed or was interrupted
            if [ -f "${DIR_OCR}/${BASE_FILENAME}" ]; then
                rm "${DIR_SCAN}/${BASE_FILENAME}"
                debug "done"
            fi
        done
    fi
    
    sleep 5
done

#!/bin/bash

# bash script for scanbuttond
# @see https://robinclarke.net/archives/the-paperless-office-with-linux
# @see https://wiki.ubuntuusers.de/scanbuttond/
# @see https://www.street.id.au/446

# cd into current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd ${DIR}

source load_config.sh

FILE_NAME=${DIR_SCAN}/scan_`date +%Y%m%d-%H%M%S`
TMP_DIR=`mktemp -d`
TMP_PDF=${TMP_DIR}/tmp.pdf
MONOCHROME_PDF=${TMP_DIR}/monochrome.pdf
cd ${TMP_DIR}

# return all numbers of pages in our monochrome pdf that are not blank
non_blank() {
    for i in $(seq 1 $PAGES)
    do
        PERCENT=$(gs -o -  -dFirstPage=${i} -dLastPage=${i} -sDEVICE=inkcov ${MONOCHROME_PDF} | grep CMYK | nawk 'BEGIN { sum=0; } {sum += $1 + $2 + $3 + $4;} END { printf "%.5f\n", sum } ')
        if [ $(echo "$PERCENT > 0.0015" | bc) -eq 1 ]
        then
            echo $i
        else
            # just some hint for us
            echo "page $i is blank" 1>&2
        fi
    done
}

debug "start scan"

scanimage --device-name "${DEVICE_NAME}" \
    --source "${DEVICE_SOURCE}" \
    ${SCAN_OPTIONS} \
    --batch=scan_%03d.tif --format=tiff

if [ -f scan_001.tif ]; then
    ls -l scan_*.tif
    debug "create pdf"
    
    tiffcp scan_*.tif output.tif
    tiff2pdf output.tif -j -q 60 -p A4 -F > ${TMP_PDF}

    debug "remove blank pages"
        
    # create a monochrome version of our pdf
    # that helps us to detect and remove empty  (see function non_blank)
    for ORIGINAL_TIF in scan_*.tif; do
        convert -density 150 -threshold 50% ${ORIGINAL_TIF} "monochrome_${ORIGINAL_TIF//[^0-9]/}.tif"
    done
    tiffcp monochrome_*.tif monochrome.tif
    tiff2pdf monochrome.tif -d -p A4 -F > ${MONOCHROME_PDF}

    PAGES=$(pdfinfo $TMP_PDF | grep ^Pages: | tr -dc '0-9')
    pdftk ${TMP_PDF} cat $(non_blank) output ${FILE_NAME}.pdf

else
    debug "Error: no images found"
fi

debug "cleaning up"

cd ..
rm -rf ${TMP_DIR}

debug "done"
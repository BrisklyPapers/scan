This collection provides some scripts that help you to scan some documents and create searchable pdf files on the fly

## Prerequisites

    sudo apt-get install \
      sane sane-utils libsane-extras xsane \
      scanbuttond \
      libtiff5 libtiff-tools \
      imagemagick \
      pdftk \
      unpaper \
      ghostscript \
      tesseract-ocr tesseract-ocr-deu \
      python3-pip
  
    pip3 install --user ocrmypdf 

## Important Files

- example.config # this file contains the configuration for all scripts
- scan2pdf.sh # trigger this script to scan a document and create a pdf file
- txt2pdf.sh # parse pdf files to create searchable pdf files

## Getting started

1. Copy example.config to scan.config and edit the file to meet your system
2. Scan one or more documents with `./scan2pdf.sh`
3. Create searchable pdf files with `./txt2pdf.sh`. This script runs in an infinite loop and parses each new pdf file directly. Processing may take a few minutes

You can use `scan2pdf` with scanbd (scanbuttond) if you want to trigger a scan on button click in your scanner (currently tested with Fujitsu ScanSnap ix500). You just need to edit `/etc/scanbd/scanbd.conf` and add scan2pdf.sh to to action scan instead of "script = `test.script`". Run the daemon witn `scanbd -d1 -f`

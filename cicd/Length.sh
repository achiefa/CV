#!/bin/bash

set -e

pdfinfo main.pdf

NumPages=$(pdfinfo main.pdf | grep "^Pages:" | awk '{print $2}')

echo "Number of pages: ${NumPages}"

if [ ${NumPages} -ne 2 ]; then
  echo "The document is too long!"
  exit 1
else
  echo "The document is the correct length."
fi
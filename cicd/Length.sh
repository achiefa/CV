#!/bin/bash
#
# Check that a CV PDF is at most two pages.
# Usage: cicd/Length.sh [file.pdf]   (defaults to main.pdf for backwards compatibility)

set -e

PDF="${1:-main.pdf}"

if [ ! -f "${PDF}" ]; then
  echo "No such file: ${PDF}"
  exit 1
fi

pdfinfo "${PDF}"

NumPages=$(pdfinfo "${PDF}" | grep "^Pages:" | awk '{print $2}')

echo "Number of pages in ${PDF}: ${NumPages}"

if [ "${NumPages}" -gt 2 ]; then
  echo "The document is too long!"
  exit 1
else
  echo "The document is the correct length."
fi

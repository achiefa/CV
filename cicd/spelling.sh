#!/bin/bash
#
# Spell-check the rendered text of a CV PDF.
#
# Checking the PDF rather than the .tex source means LaTeX markup -- entry keys,
# command names, lengths, arXiv IDs -- never reaches the spell checker and never
# needs a dict/words entry. dict/words then holds domain vocabulary only.
#
# Usage: cicd/spelling.sh <file.pdf>

set -euo pipefail

PDF="${1:?usage: cicd/spelling.sh <file.pdf>}"

if [ ! -f "${PDF}" ]; then
  echo "No such file: ${PDF}"
  exit 1
fi

TEXT=$(pdftotext -nopgbrk "${PDF}" -)

# \TODO placeholders render the literal string into the PDF.
if grep -q "TODO" <<<"${TEXT}"; then
  echo "Unresolved \\TODO placeholder in ${PDF}:"
  grep -n "TODO" <<<"${TEXT}"
  exit 1
fi

# Strip what renders as visible text but is not prose: emails, URLs, arXiv IDs.
# Then drop tokens under three characters -- "Ph" (from Ph.D.) and "st" (from
# the 31$^{st}$ superscript) survive tokenisation but carry no signal.
errors=$(sed -E 's#[^ ]+@[^ ]+# #g;
                 s#(https?://|www\.)[^ ]+# #g;
                 s#[A-Za-z0-9.-]+\.(com|org|net|io|uk)# #g;
                 s#arXiv:[^ ]+# #g' <<<"${TEXT}" \
  | hunspell -d en_GB -l -p dict/words \
  | awk 'length($0) >= 3' \
  | sort -u)

if [ -n "${errors}" ]; then
  echo ""
  echo "======================================================"
  echo "Spelling errors in ${PDF}."
  echo "Either fix, or add to \"dict/words\""
  echo "======================================================"
  echo ""
  echo "${errors}"
  exit 1
fi

echo "No spelling errors in ${PDF}."

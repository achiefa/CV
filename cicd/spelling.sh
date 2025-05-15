#!bin/bash
#
# Check the spelling of the LaTeX file and fail if there are errors.
#

# Find all .tex files in current directory and subdirectories
tex_files=$(find . -type f -name "*.tex")

# Check if any .tex files are found
if [ -z "$tex_files" ]; then
  echo "No .tex files found."
  exit 0
fi

# Variable to track if any spelling errors are found
errors_found=0

# Get the dict paths
# dic_path=$(hunspell -d en_GB -D 2>&1 | grep -o '/.*GB\.dic' | head -n 1)
# echo $dic_path
# if [ -z "$dic_path" ]; then
#     echo "No dictionary file found!"
#     exit 1
# fi

# # Some words need to be appended by hand
# echo Ph >> $dic_path

# Loop through each .tex file
for file in $tex_files; do
  echo -e "\nChecking spelling for file: $file"
  # Spell checker with hunspell
  # -d en_GB: British English
  # -t: TeX mode
  # -a: Morphological analysis
  # -l: List only misspelled words
  # -d dict/words: Adds custom dictionary located in dict/words
  hunspellOutput="$(hunspell -d en_GB -t -a -l -p dict/words $file)"
  hunspellOutput=$(echo "$hunspellOutput" | grep -v "\bPh\b")
  echo ${hunspellOutput}

  if [ "${hunspellOutput}" != "" ]; then
    # Spelling errors
    echo ""
    echo "======================================================"
    echo "There are spelling errors listed below in file: $file."
    echo "Either fix, or add to \"dict/words\""
    echo "======================================================"
    echo ""
    #hunspell -d en_GB -t -a -l -p dict/words $file

    # Check unwanted words
    echo "$hunspellOutput" | tr ' ' '\n' | sort | uniq
    errors_found=1
  else
    echo "Spelling looks good to me in $file"

  fi
done

# Exit with an error if any spelling mistakes were found
if [ $errors_found -eq 1 ]; then
  echo "Spelling errors were found in one or more files. Exiting with error."
  exit 1
else
  echo "All .tex files look good. No spelling errors found."
  exit 0
fi
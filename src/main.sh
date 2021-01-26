#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
THEPACK="${DIR}/$(basename "${BASH_SOURCE[0]}")"
INPUT="$1"
OUTPUT="$2"
OLD_PWD="$(pwd)"

# Validate input parameters
if [ -z "$INPUT" -o -z "$OUTPUT" ]; then
  echo "Usage: $0 INPUT_PDF OUTPUT_PDFA"
  exit 1
fi
if [ "$INPUT" = "$OUTPUT" ]; then
  echo "Error: Input and output are the same file."
  exit 1
fi

# Get absolute path to input/output
OLD_PWD=$(pwd)
echo "$INPUT" | grep -E '^/' || INPUT="$OLD_PWD/$INPUT"
echo "$OUTPUT" | grep -E '^/' || OUTPUT="$OLD_PWD/$OUTPUT"
echo "Absolute input path: $INPUT"
echo "Absolute output path: $OUTPUT"

# Get PDF metadata
if ! [ -x "$(command -v pdfinfo)" ] ; then
  echo "pdfinfo not found. Cannot read PDF metadata (Author/Title) without it" 1>&2
  exit 1
fi
AUTHOR=$(pdfinfo $INPUT | sed -nE 's/^Author: *(.*) *$/\1/p')
TITLE=$(pdfinfo $INPUT | sed -nE 's/^Title: *(.*) *$/\1/p')
echo -e "PDF Metadata:\n  - Author: $AUTHOR\n  - Title: $TITLE\n"
TITLE_SED=$(echo $TITLE | sed -E "s/'/\\\\'/")
AUTHOR_SED=$(echo $AUTHOR | sed -E "s/'/\\\\'/")

# Unpack the support files hidden in this script
WDIR=$(mktemp -d)
cd $WDIR
tail -n +$(($(grep -ahn  '^__GENERATE_PDFA_SH_MARKER__' "$THEPACK" | cut -f1 -d:) +1)) "$THEPACK" | tar zx

# Patch PDFA_bu.ps file with metadata and absolute paths
if ! ( sed -iE "s\$__TITLE__\$$TITLE_SED\$" PDFA_bu.ps ); then
  echo "Failed to replace title $TITLE. Do it manually or remove backward slashes from PDF metadata"
  exit 1
fi
if ! ( sed -iE "s\$__AUTHOR__\$$AUTHOR_SED\$" PDFA_bu.ps ); then
  echo "Failed to replace author $AUTHOR. Do it manually or remove backward slashes from PDF metadata"
  exit 1
fi
if ! ( sed -iE "s\$__WDIR__\$$WDIR\$" PDFA_bu.ps ); then
  echo "Failed to set __WDIR__ to $WDIR. Broken sed or MacOS?"
  exit 1
fi

# Convert to PDF/A-1b with PDF 1.4
# Ghostscript documentation:
# https://ghostscript.com/doc/9.53.2/VectorDevices.htm#PDFA
gs -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
   -dPDFA=1 \
   -dPDFACompatibilityPolicy=1 \
   -sProcessColorModel=DeviceRGB \
   -sColorConversionStrategy=RGB \
   -sOutputFile="$OUTPUT" \
   ./PDFA_bu.ps \
   "$INPUT"
if [ "$?" != "0" ]; then
  echo "gs failed to convert $INPUT into $OUTPUT"
  exit 1
fi

# Show metadata (if installed)
LOG=$(mktemp)
if ( exiftool -a -G1 "$OUTPUT" &> "$LOG" ); then
  cat "$LOG"
else
  rm $LOG
fi

echo -e "\nWrote $OUTPUT\n" \
     "Verify:        verapdf -f 1b \"$OUTPUT\"\n" \
     "Show metadata: exiftool -a -G1 \"$OUTPUT\""

# To validate the output PDF/A file:
#   $ verapdf -f 1b ~/ufsc/lapesd-thesis/master_dissertation-pdfa.pdf
# (add --format text before FILE for a simple PASS/FAIL text message instead of XML)

exit 0
__GENERATE_PDFA_SH_MARKER__

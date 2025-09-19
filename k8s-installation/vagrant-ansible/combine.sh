#!/bin/bash

# Script to combine files into a single file with path headers
# Usage: ./combine.sh [directory] [output_file]
# If directory is specified, combines files from that directory and subdirectories.
# If no directory is specified, combines from the entire project (current directory).
# Output file defaults to <basename_directory>-combined.txt if directory specified,
# or combined_output.txt if not.

DIRECTORY="${1:-.}"

# Determine basename of the directory for default output name
if [ "$DIRECTORY" = "." ]; then
    BASENAME="project"
else
    BASENAME=$(basename "$DIRECTORY")
fi

# Shift arguments if directory was provided
if [ $# -ge 1 ] && [ "$1" != "." ]; then
    shift
fi

DEFAULT_OUTPUT="${BASENAME}-combined.txt"
OUTPUT_FILE="${1:-$DEFAULT_OUTPUT}"

# Function to process each file
process_file() {
    local file="$1"
    echo "=== $file ==="
    echo ""
    cat "$file"
    echo ""
    echo ""
}

# Export the function so it can be used by find
export -f process_file

# Clear the output file if it exists
> "$OUTPUT_FILE"

# Build find command with exclusions
find "$DIRECTORY" \
  -type d \( -name '.vscode' -o -name '.vagrant' -o -name '.qodo' -o -name 'artifacts' -o -name 'files' \) -prune -o \
  -type f \
  ! -name "$OUTPUT_FILE" \
  ! -name "ansible-tree.md" \
  ! -iname "readme.md" \
  -exec bash -c 'process_file "$0"' {} \; >> "$OUTPUT_FILE"

echo "All files have been combined into: $OUTPUT_FILE"
echo "Total files processed: $(find "$DIRECTORY" \
  -type d \( -name '.vscode' -o -name '.vagrant' -o -name '.qodo' -o -name 'files' \) -prune -o \
  -type f \
  ! -name "$OUTPUT_FILE" \
  ! -name "ansible-tree.md" \
  ! -iname "readme.md" \
  -print | wc -l)"
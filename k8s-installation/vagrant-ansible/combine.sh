#!/bin/bash

# Script to combine all files into a single file with path headers
# Usage: ./combine_files.sh [output_file]

OUTPUT_FILE="${1:-combined_output.txt}"

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
find . \
  -type d \( -name '.vscode' -o -name '.vagrant' -o -name '.qodo' -o -name 'files' \) -prune -o \
  -type f \
  ! -name "$OUTPUT_FILE" \
  ! -name "ansible-tree.md" \
  ! -iname "readme.md" \
  -exec bash -c 'process_file "$0"' {} \; >> "$OUTPUT_FILE"

echo "All files have been combined into: $OUTPUT_FILE"
echo "Total files processed: $(find . \
  -type d \( -name '.vscode' -o -name '.vagrant' -o -name '.qodo' -o -name 'files' \) -prune -o \
  -type f \
  ! -name "$OUTPUT_FILE" \
  ! -name "ansible-tree.md" \
  ! -iname "readme.md" \
  -print | wc -l)"
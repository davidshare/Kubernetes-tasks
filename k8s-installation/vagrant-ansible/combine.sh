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

# Find all files (excluding directories) and process them
find . -type f -not -path "./$OUTPUT_FILE" -exec bash -c 'process_file "$0"' {} \; >> "$OUTPUT_FILE"

echo "All files have been combined into: $OUTPUT_FILE"
echo "Total files processed: $(find . -type f -not -path "./$OUTPUT_FILE" | wc -l)"
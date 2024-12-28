#!/bin/bash

# Check if directory is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

directory="$1"

# Check if directory exists
if [ ! -d "$directory" ]; then
    echo "Error: Directory '$directory' not found"
    exit 1
fi

find "$directory" -type f -name "*.html" -exec sh -c '
    for file do
        # Create a temporary file
        temp_file=$(mktemp)
        
        # Convert the file to UTF-8, explicitly replacing the replacement character
        iconv -f UTF-8 -t UTF-8//IGNORE < "$file" | \
        perl -pe 's/\x{ef}\x{bf}\x{bd}//gi' > "$temp_file"
        
        # Check if any changes were made
        if ! cmp -s "$file" "$temp_file"; then
            mv "$temp_file" "$file"
            echo "Modified: $file"
        else
            rm "$temp_file"
            echo "No changes needed: $file"
        fi
    done
' sh {} +

echo "Finished processing HTML files"
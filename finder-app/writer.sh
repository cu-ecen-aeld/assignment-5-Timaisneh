#!/bin/sh

# Check if both arguments are provided
if [ $# -lt 2 ]; then
    echo "Error: Please provide both writefile and writestr."
    exit 1
fi

writefile="$1"
writestr="$2"

# Create the directory path if it doesn't exist
mkdir -p "$(dirname "$writefile")" || {
    echo "Error: Unable to create directory path for $writefile."
    exit 1
}

# Write the content to the file
echo "$writestr" > "$writefile" || {
    echo "Error: Unable to write to $writefile."
    exit 1
}

echo "File created successfully: $writefile"


#!/bin/bash

# Function to display usage information
function display_usage {
    echo "Usage: $0 -o <srpm_folder> <spec_file1.spec> [spec_file2.spec ...]"
}

# Parse command line arguments
while getopts "o:" opt; do
    case $opt in
        o)
            SRPM_FOLDER="$OPTARG"
            ;;
        *)
            display_usage
            exit 1
            ;;
    esac
done

# Remove the processed options from the arguments list
shift $((OPTIND - 1))

# Verify if at least one .spec file is provided as a parameter
if [ $# -lt 1 ]; then
    display_usage
    exit 1
fi

# Create the specified srpm directory if it doesn't exist
mkdir -p "$SRPM_FOLDER"

# Loop through each .spec file and generate the .src.rpm packages
for SPEC_FILE in "$@"; do
    # Expand the wildcard if it matches any .spec files
    for FILE in $SPEC_FILE; do
        # Check if the .spec file exists
        if [ ! -f "$FILE" ]; then
            echo "The file $FILE does not exist in the current directory. Skipping..."
            continue
        fi

        # Get the name and version from the .spec file
        NAME=$(rpmspec -q --queryformat '%{name}\n' "$FILE" | head -1 )
        VERSION=$(rpmspec -q --queryformat '%{version}\n' "$FILE" | head -1 )

        # Create the tar.gz file containing the source files
        tar -czvf "$NAME-$VERSION.tar.gz" --exclude="$NAME-$VERSION.tar.gz" --exclude=".git" --exclude=".svn" --exclude=".hg" --exclude=".bzr" --exclude=".DS_Store" *

        # Move the .tar.gz file to the SOURCES directory
        mv "$NAME-$VERSION.tar.gz" ~/rpmbuild/SOURCES/

        # Generate the .src.rpm package
        rpmbuild -bs "$FILE"

        # Get the generated .src.rpm package name
        SRPM_NAME=$(rpmbuild -bs --nodeps "$FILE" 2>&1 | grep -oP '(?<=Wrote: ).*\.src\.rpm')

        # Check if the .src.rpm package was generated successfully
        if [ -z "$SRPM_NAME" ]; then
            echo "Error generating the .src.rpm package for $FILE. Please check the .spec file and the source files."
        else
            # Move the .src.rpm package to the specified srpm directory
            mv "$SRPM_NAME" "$SRPM_FOLDER/"
            echo "The .src.rpm package for $FILE has been generated and moved to the $SRPM_FOLDER directory."
        fi
    done
done
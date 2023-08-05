#!/bin/bash
set -e

# Function to display usage information
function display_usage {
    echo "Usage: $0 -r <mock_config> -o <rpm_folder> <src_rpm_file1.src.rpm> [src_rpm_file2.src.rpm ...]"
}

# Initialize variables
RPM_FOLDER=""
MOCK_CONFIG=""
MOCK_CONF_FOLDER="/etc/mock"

# Parse command line arguments
while getopts "r:o:" opt; do
    case $opt in
        r)
            MOCK_CONFIG="$OPTARG"
            ;;
        o)
            RPM_FOLDER="$OPTARG"
            ;;
        *)
            display_usage
            exit 1
            ;;
    esac
done

# Verify required parameters
if [ -z "$MOCK_CONFIG" ] || [ -z "$RPM_FOLDER" ] || [ $# -lt 1 ]; then
    display_usage
    exit 1
fi


CFG_LIST=$(ls ${MOCK_CONF_FOLDER}/*.cfg | awk -F/ '{print $NF}' | sed 's/\.cfg$//')

if [ ! -f "${MOCK_CONF_FOLDER}/${MOCK_CONFIG}.cfg" ]; then
    echo "MOCK_CONFIG ${MOCK_CONFIG} does not exist. Should be one of: "
    echo "$CFG_LIST"
    exit 1
fi

# Remove the processed options from the arguments list
shift $((OPTIND - 1))

# Create the specified rpm directory if it doesn't exist
mkdir -p "$RPM_FOLDER"

# Loop through each .src.rpm file and generate the RPM packages
for SRC_RPM_FILE in "$@"; do
    # Expand the wildcard if it matches any .src.rpm files
    for FILE in $SRC_RPM_FILE; do
        # Check if the .src.rpm file exists
        if [ ! -f "$FILE" ]; then
            echo "The file $FILE does not exist in the current directory. Skipping..."
            continue
        fi

        # Extract the name of the package from the .src.rpm filename
        PACKAGE_NAME=$(rpm -qp --queryformat '%{NAME}' "$FILE")

        # Rebuild the RPM package using mock
        mock -r "$MOCK_CONFIG" --rebuild "$FILE"

        # Move the generated RPM packages from mock's result directory to the specified rpm directory
        mock_result_dir=/var/lib/mock/"$MOCK_CONFIG"/result
        mv "$mock_result_dir"/*.rpm "$RPM_FOLDER/"
        echo "RPM packages for $PACKAGE_NAME have been generated and moved to the $RPM_FOLDER directory."
    done
done

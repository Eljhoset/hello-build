#!/bin/bash

# Function to display usage information
function display_usage {
    echo "Usage: $0 -r <mock_config> -o <rpm_folder> -s <srpm_folder> --repo-host <repo_host> <spec_file1.spec> [spec_file2.spec ...]"
}
# Initialize variables
MOCK_CONFIG="epel-8-x86_64"
RPM_FOLDER="./rpm"
SRPM_FOLDER="./srpm"
REPO_HOST="http://server"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -r)
            MOCK_CONFIG="$2"
            shift 2
            ;;
        -o)
            RPM_FOLDER="$2"
            shift 2
            ;;
        -s)
            SRPM_FOLDER="$2"
            shift 2
            ;;
        --repo-host)
            REPO_HOST="$2"
            shift 2
            ;;
        *)
            break
            ;;
    esac
done


# Verify required parameters
if [ -z "$MOCK_CONFIG" ] || [ -z "$RPM_FOLDER" ] || [ -z "$SRPM_FOLDER" ] || [ $# -lt 1 ]; then
    display_usage
    exit 1
fi

# Remove the processed options from the arguments list
shift $((OPTIND - 1))

echo "Mock Config: $MOCK_CONFIG"
echo "RPM Folder: $RPM_FOLDER"
echo "SRPM Folder: $SRPM_FOLDER"
echo "Repo Host: $REPO_HOST"
echo "Spec Files: $@"

update_nginx_redirect.sh -c /etc/nginx/conf.d/redirect.conf "$REPO_HOST"

# Run srpm script to generate .src.rpm files
srpm_script="srpm.sh"
$srpm_script -o "$SRPM_FOLDER" "$@"

# Run rpm script to generate RPMs using .src.rpm files
rpm_script="rpm.sh"
$rpm_script -r "$MOCK_CONFIG" -o "$RPM_FOLDER" "$SRPM_FOLDER"/*.src.rpm

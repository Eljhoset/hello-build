#!/bin/bash

# Default value for the NGINX configuration file
default_nginx_config_file="/etc/nginx/conf.d/redirect.conf"

# Placeholder value
placeholder="{HOST}"

# Function to display script usage
show_usage() {
    echo "Usage: $0 [-c nginx_config_file] <new_value>"
    exit 1
}

# Process command-line options
while getopts "c:" opt; do
    case $opt in
        c)
            nginx_config_file="$OPTARG"
            ;;
        *)
            show_usage
            ;;
    esac
done
shift $((OPTIND - 1))

# Check if the new value is provided as an argument
if [ $# -ne 1 ]; then
    show_usage
fi

new_value="$1"

# Perform replacement using sed
sed -i "s|$placeholder|$new_value|g" $nginx_config_file

# Verify NGINX configuration syntax
nginx -t

if [ $? -eq 0 ]; then
    # Restart NGINX if the verification was successful
    nginx
    echo "NGINX configuration updated and restarted."
else
    echo "NGINX configuration update failed. Please check the configuration."
fi

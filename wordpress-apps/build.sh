#!/bin/bash

# Define a function to handle errors
handle_error() {
    echo "An error occurred in the script"

    docker context use default
}

# Trap errors and call handle_error function
trap 'handle_error' ERR

set -e

# Prompt user for Docker context choice
echo "Select Docker context:"
echo "1. Default"
echo "2. Remote"
read -p "Enter your choice (1 or 2): " choice

case $choice in
    1)
        docker context use default
        ;;
    2)
        docker context use remote
        ;;
    *)
        echo "Invalid choice. Using default Docker context."
        docker context use default
        ;;
esac

docker build --pull -t registry.example.com/platform/wordpress:6.9.2-php8.3-r1 .

docker context use default

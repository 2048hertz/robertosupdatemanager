#!/bin/bash

# Current version
CURRENT_VERSION="0.1"

# GitHub repository URLs
MAJOR_UPDATE_REPO_URL="https://github.com/2048hertz/RobertOS"
MINOR_UPDATE_REPO_URL="https://github.com/2048hertz/robertos-minor-update-repo"

# Function to display the update manager UI
display_update_manager_ui() {
    clear
    echo "======================================="
    echo "        RobertOS Update Manager        "
    echo "======================================="
    echo ""
    echo "1. Check for Updates"
    echo "2. Exit"
    echo ""
    read -p "Enter your choice: " choice
    case "$choice" in
        1) check_for_updates ;;
        2) exit ;;
        *) echo "Invalid choice. Please try again." ;;
    esac
}

# Function to check for updates
check_for_updates() {
    echo "Checking for updates..."
    if check_for_update "$MAJOR_UPDATE_REPO_URL" "major"; then
        return
    fi
    if check_for_update "$MINOR_UPDATE_REPO_URL" "minor"; then
        return
    fi
    echo "No updates available."
}

# Function to get the latest release version from a repository URL
get_latest_release_version() {
    repo_url="$1"
    curl -sSL "$repo_url/releases/latest" | grep -o '"tag_name":.*' | sed -E 's/.*"([^"]+)".*/\1/'
}

# Function to compare version numbers and check if a newer version exists
is_newer_version() {
    [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n 1)" != "$1" ]
}

# Function to check for updates in a repository
check_for_update() {
    local repo_url="$1"
    local update_type="$2"
    local latest_version="$(get_latest_release_version "$repo_url")"
    if [ -n "$latest_version" ] && is_newer_version "$latest_version" "$CURRENT_VERSION"; then
        echo "Latest $update_type update version: $latest_version"
        echo "$update_type update available. Downloading..."
        download_and_execute_update "$repo_url" "$latest_version"
        return 0
    fi
    return 1
}

# Function to download and execute the update
download_and_execute_update() {
    local repo_url="$1"
    local version="$2"
    local download_url="$repo_url/releases/download/$version/update.sh"
    local temp_dir=$(mktemp -d)
    local download_file="$temp_dir/update.sh"
    curl -sSL -o "$download_file" "$download_url"
    chmod +x "$download_file"
    echo "Update downloaded. Executing..."
    "$download_file"
}

# Main function
main() {
    display_update_manager_ui
}

# Call the main function
main
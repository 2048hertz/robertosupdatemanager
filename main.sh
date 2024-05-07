#!/bin/bash

# GitHub repository URLs
MAJOR_UPDATE_REPO_URL="https://github.com/2048hertz/RobertOS"
MINOR_UPDATE_REPO_URL="https://github.com/2048hertz/robertos-minor-update-repo"

# Directory to store downloaded updates
UPDATE_DIR="updates"

# Function to check for updates
check_for_updates() {
    # Check for major version updates
    major_update_version=$(get_latest_release_version "$MAJOR_UPDATE_REPO_URL")
    if [ ! -z "$major_update_version" ]; then
        echo "Latest major update version: $major_update_version"
        if is_newer_version "$major_update_version"; then
            download_update "$major_update_version"
            return
        fi
    fi

    # Check for minor version updates or patches
    minor_update_version=$(get_latest_release_version "$MINOR_UPDATE_REPO_URL")
    if [ ! -z "$minor_update_version" ]; then
        echo "Latest minor update version: $minor_update_version"
        if is_newer_version "$minor_update_version"; then
            download_update "$minor_update_version"
            return
        fi
    fi

    echo "No updates available."
}

# Function to get the latest release version from a repository URL
get_latest_release_version() {
    repo_url="$1"
    # Construct URL to latest release
    releases_url="$repo_url/releases/latest"
    # Send a GET request to GitHub API to get the latest release info
    response=$(curl -s -o /dev/null -w "%{http_code}" "$releases_url")
    if [ "$response" -eq 200 ]; then
        latest_version=$(curl -s "$releases_url" | grep -o '"tag_name":.*' | sed -E 's/.*"([^"]+)".*/\1/')
        echo "$latest_version"
    else
        echo "Failed to check for updates in $repo_url."
    fi
}

# Function to compare version numbers and check if a newer version exists
is_newer_version() {
    new_version="$1"
    current_version="0.1"  # Placeholder for current version
    # Compare major and minor versions
    if [ "$new_version" \> "$current_version" ]; then
        return 0
    else
        return 1
    fi
}

# Function to download and install an update
download_update() {
    version="$1"
    # Create the updates directory if it doesn't exist
    if [ ! -d "$UPDATE_DIR" ]; then
        mkdir -p "$UPDATE_DIR"
    fi
    # Construct URL to the update file
    update_url="${MAJOR_UPDATE_REPO_URL}"
    if [[ "$version" == *"-"* ]]; then
        update_url="${MINOR_UPDATE_REPO_URL}"
    fi
    update_url="$update_url/releases/download/$version/updater.sh"
    # Download the update file
    update_file="$UPDATE_DIR/update_$version.sh"
    curl -s -L -o "$update_file" "$update_url"
    if [ $? -eq 0 ]; then
        echo "Update downloaded successfully."
        # Run the update script
        bash "$update_file"
    else
        echo "Failed to download the update."
    fi
}

# Main function
check_for_updates
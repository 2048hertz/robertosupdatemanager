#!/bin/bash

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
    case $choice in
        1) check_for_updates ;;
        2) exit ;;
        *) echo "Invalid choice. Please try again." ;;
    esac
}

# Function to check for updates
check_for_updates() {
    echo "Checking for updates..."
    # Check for major version updates
    major_update_version=$(get_latest_release_version "$MAJOR_UPDATE_REPO_URL")
    if [ ! -z "$major_update_version" ]; then
        echo "Latest major update version: $major_update_version"
        if is_newer_version "$major_update_version"; then
            echo "Major update available. Please update your system."
            return
        fi
    fi

    # Check for minor version updates or patches
    minor_update_version=$(get_latest_release_version "$MINOR_UPDATE_REPO_URL")
    if [ ! -z "$minor_update_version" ]; then
        echo "Latest minor update version: $minor_update_version"
        if is_newer_version "$minor_update_version"; then
            echo "Minor update available. Please update your system."
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

# Function to create the .desktop file
create_desktop_entry() {
    cat > RobertOS-Update-Manager.desktop <<EOF
[Desktop Entry]
Type=Application
Name=RobertOS Update Manager
Exec=$(realpath $0)
Icon=/usr/bin/RobertOS-assets/logofull.png
Terminal=false
Categories=Utility;
EOF

    sudo mv RobertOS-Update-Manager.desktop /usr/share/applications
}

# GitHub repository URLs
MAJOR_UPDATE_REPO_URL="https://github.com/2048hertz/RobertOS"
MINOR_UPDATE_REPO_URL="https://github.com/2048hertz/robertos-minor-update-repo"

# Directory to store downloaded updates
UPDATE_DIR="updates"

# Main function
main() {
    # Create .desktop file
    create_desktop_entry

    # Display update manager UI
    display_update_manager_ui
}

# Call the main function
main

#!/bin/bash

SCRIPT_VERSION="2.0.3"

SYSTEM_THEME_PATH="/usr/share/emulationstation/themes/es-theme-knulli"
USERDATA_THEME_PATH="/userdata/themes/es-theme-knulli"
REMOTE_SCRIPT_URL="https://raw.githubusercontent.com/symbuzzer/etk_tool/main/etk_tool.sh"
REMOTE_THEME_XML_URL="https://raw.githubusercontent.com/symbuzzer/es-theme-knulli/refs/heads/main/theme.xml"
REMOTE_BETA_VERSION_URL="https://raw.githubusercontent.com/symbuzzer/es-theme-knulli/refs/heads/main/beta.version"
REMOTE_THEME_BASE_URL="https://github.com/symbuzzer/es-theme-knulli/releases/download"

show_message() {
    echo "======================================="
    echo "$1"
    echo "======================================="
    sleep 2
}

check_internet() {
    curl -s --head https://www.avalibeyaz.com | head -n 1 | grep "200 OK" >/dev/null
}

download_file() {
    local url="$1"
    local destination="$2"
    curl -L "$url" -o "$destination"
}

save_overlay() {
    show_message "Saving overlay..."
    if sh /usr/bin/batocera-save-overlay; then
        show_message "Overlay saved successfully!"
    else
        show_message "Error: Overlay not saved!"
    fi
}

get_remote_theme_version() {
    local theme_version
    theme_version=$(curl -s "$REMOTE_THEME_XML_URL" | grep -Po '<v\.themeVersion>\K[^<]+')

    local beta_version
    beta_version=$(curl -s "$REMOTE_BETA_VERSION_URL" | grep -Po '<v\.themeVersion>\K[^<]+')

    if [ -n "$beta_version" ] && [[ "$beta_version" > "$theme_version" ]]; then
        echo "$beta_version"
        show_message "Beta version of theme detected: v$beta_version"
    else
        echo "$theme_version"
        show_message "Latest theme version detected: v$theme_version"
    fi
}

get_local_theme_version() {
    local theme_path="$1/theme.xml"
    if [ -f "$theme_path" ]; then
        grep -Po '<v\.themeVersion>\K[^<]+' "$theme_path"
    else
        echo "0"
    fi
}

update_theme() {
    local destination="$1"
    local version="$2"
    local download_url="$REMOTE_THEME_BASE_URL/v$version/es-theme-knulli.zip"

    show_message "Downloading theme v$version..."
    local zip_path="$destination/es-theme-knulli.zip"
    download_file "$download_url" "$zip_path"

    local theme_folder_path="$destination/es-theme-knulli"
    if [ -d "$theme_folder_path" ]; then
        rm -rf "$theme_folder_path"
    fi

    unzip "$zip_path" -d "$destination"
    rm -f "$zip_path"

    if [ -d "$SYSTEM_THEME_PATH" ]; then
        save_overlay
    fi
    show_message "Theme v$version update complete!"
}

main() {
    show_message "Starting ETK Tool v$SCRIPT_VERSION by Ali BEYAZ..."

    if ! check_internet; then
        show_message "No internet connection. Exiting..."
        exit 1
    fi

    local remote_script_version
    remote_script_version=$(curl -s "$REMOTE_SCRIPT_URL" | grep -Po 'scriptVersion\s*=\s*"\K[^"]+')
    if [ "$remote_script_version" ] && [ "$remote_script_version" != "$SCRIPT_VERSION" ]; then
        show_message "ETK Tool v$remote_script_version is available! Updating now..."
        download_file "$REMOTE_SCRIPT_URL" "/userdata/roms/pygame/etk_tool.sh"
        show_message "ETK Tool updated! Please restart."
        exit 0
    fi

    local theme_destination
    if [ -d "$SYSTEM_THEME_PATH" ]; then
        theme_destination="/usr/share/emulationstation/themes"
    elif [ -d "$USERDATA_THEME_PATH" ]; then
        theme_destination="/userdata/themes"
    fi

    if [ "$theme_destination" ]; then
        local local_theme_version
        local remote_theme_version
        local_theme_version=$(get_local_theme_version "$theme_destination")
        remote_theme_version=$(get_remote_theme_version)

        if [ "$remote_theme_version" ] && [[ "$remote_theme_version" > "$local_theme_version" ]]; then
            show_message "Updating theme to v$remote_theme_version..."
            update_theme "$theme_destination" "$remote_theme_version"
        else
            show_message "Theme v$local_theme_version is up to date. No updates available."
        fi
    else
        show_message "Theme not installed yet!"
        local remote_theme_version
        remote_theme_version=$(get_remote_theme_version)
        update_theme "/userdata/themes" "$remote_theme_version"
    fi

    show_message "Done! Exiting..."
}

main

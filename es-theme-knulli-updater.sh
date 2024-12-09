#!/bin/bash

version="1.0.0"

script_dir="$(dirname "$(realpath "$0")")"

curl -L https://raw.githubusercontent.com/symbuzzer/etk_tool/refs/heads/main/es-theme-knulli-updater.sh -o "$script_dir/es-theme-knulli-updater.sh"

if [ ! -f "$script_dir/etk_tool.pygame" ]; then
    curl -L https://raw.githubusercontent.com/symbuzzer/etk_tool/refs/heads/main/etk_tool.pygame -o "$script_dir/etk_tool.pygame"
fi

if command -v python3 &>/dev/null; then
    python3 "$script_dir/etk_tool.pygame"
elif command -v python &>/dev/null; then
    python "$script_dir/etk_tool.pygame"
else
    exit 1
fi

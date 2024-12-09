#!/bin/bash

version="1.0.1"

script_dir="$(dirname "$(realpath "$0")")"
tool_dir="$script_dir/etk_tool"

mkdir -p "$tool_dir"

curl -L https://raw.githubusercontent.com/symbuzzer/etk_tool/refs/heads/main/es-theme-knulli-updater.sh -o "$script_dir/es-theme-knulli-updater.sh"

if [ ! -f "$tool_dir/etk_tool.pygame" ]; then
    curl -L https://raw.githubusercontent.com/symbuzzer/etk_tool/refs/heads/main/etk_tool.pygame -o "$tool_dir/etk_tool.pygame"
fi

if command -v python3 &>/dev/null; then
    python3 "$tool_dir/etk_tool.pygame"
elif command -v python &>/dev/null; then
    python "$tool_dir/etk_tool.pygame"
else
    exit 1
fi

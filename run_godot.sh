#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_GODOT="$SCRIPT_DIR/.tools/Godot_v4.5-stable_linux.x86_64"

if [[ -x "$LOCAL_GODOT" ]]; then
	exec "$LOCAL_GODOT" "$@"
fi

if command -v godot4 >/dev/null 2>&1; then
	exec godot4 "$@"
fi

if command -v godot >/dev/null 2>&1; then
	exec godot "$@"
fi

if command -v flatpak >/dev/null 2>&1; then
	if flatpak info org.godotengine.Godot >/dev/null 2>&1; then
		exec flatpak run org.godotengine.Godot "$@"
	fi
fi

echo "Godot executable not found. Install Godot 4 and ensure godot4 or godot is on PATH, or install Flatpak app org.godotengine.Godot." >&2
exit 127
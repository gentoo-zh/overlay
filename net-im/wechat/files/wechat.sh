#!/bin/bash

set -euo pipefail

# Set during ebuild configuration
EBUILD_WAYLAND=false

gcc_runtime_path() {
    if command -v gcc-config >/dev/null 2>&1; then
        gcc-config --get-lib-path 2>/dev/null || true
    fi
}

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
declare -a wechat_user_flags=()

if [[ -f "${XDG_CONFIG_HOME}/wechat-flags.conf" ]]; then
    while IFS= read -r line; do
        if [[ ! "${line}" =~ ^[[:space:]]*# ]] && [[ -n "${line}" ]]; then
            wechat_user_flags+=("${line}")
        fi
    done < "${XDG_CONFIG_HOME}/wechat-flags.conf"
fi

export QT_AUTO_SCREEN_SCALE_FACTOR=1
if "${EBUILD_WAYLAND}" && [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    export QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-wayland;xcb}"
else
    export QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-xcb}"
fi

gcc_lib_path="$(gcc_runtime_path)"
if [[ -n "${gcc_lib_path}" ]]; then
    export LD_LIBRARY_PATH="${gcc_lib_path}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
fi

exec /opt/wechat/wechat "${wechat_user_flags[@]}" "$@"

#!/bin/bash

set -euo pipefail

# Set during ebuild configuration
EBUILD_WAYLAND=false

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

show_error() {
    local title="wechat-bwrap"
    local message="$1"

    if command_exists kdialog; then
        kdialog --error "${message}" --title "${title}" --icon wechat
    elif command_exists zenity; then
        zenity --error --title "${title}" --icon-name wechat --text "${message}"
    else
        printf 'wechat-bwrap: %s\n' "${message}" >&2
    fi
}

require_path() {
    local path="$1"

    if [[ ! -e "${path}" ]]; then
        show_error "Required path is missing: ${path}"
        exit 1
    fi
}

read_config_flags() {
    local file="$1"
    local -n out_ref="$2"

    if [[ ! -f "${file}" ]]; then
        return
    fi

    while IFS= read -r line; do
        if [[ ! "${line}" =~ ^[[:space:]]*# ]] && [[ -n "${line}" ]]; then
            out_ref+=("${line}")
        fi
    done < "${file}"
}

read_bwrap_flags() {
    local file="$1"
    local -n out_ref="$2"
    local line expanded_line
    local -a parts

    if [[ ! -f "${file}" ]]; then
        return
    fi

    while IFS= read -r line; do
        if [[ "${line}" =~ ^[[:space:]]*# ]] || [[ -z "${line}" ]]; then
            continue
        fi

        if ! eval "expanded_line=\"$line\""; then
            show_error "Failed to parse ${file}: ${line}"
            exit 1
        fi

        parts=()
        read -r -a parts <<< "${expanded_line}"
        out_ref+=("${parts[@]}")
    done < "${file}"
}

gcc_runtime_path() {
    if command_exists gcc-config; then
        gcc-config --get-lib-path 2>/dev/null || true
    fi
}

resolve_download_dir() {
    local user_dirs_file="${XDG_CONFIG_HOME}/user-dirs.dirs"
    local line expanded_line

    if [[ -n "${XDG_DOWNLOAD_DIR:-}" ]]; then
        printf '%s\n' "${XDG_DOWNLOAD_DIR}"
        return
    fi

    if [[ -f "${user_dirs_file}" ]]; then
        line="$(grep -E '^XDG_DOWNLOAD_DIR=' "${user_dirs_file}" || true)"
        if [[ -n "${line}" ]]; then
            line="${line#XDG_DOWNLOAD_DIR=}"
            if eval "expanded_line=${line}"; then
                printf '%s\n' "${expanded_line}"
                return
            fi
        fi
    fi

    printf '%s\n' "${REAL_HOME}/Downloads"
}

USER_RUN_DIR="/run/user/$(id -u)"
REAL_HOME="${HOME}"
XAUTHORITY="${XAUTHORITY:-${REAL_HOME}/.Xauthority}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${REAL_HOME}/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-${REAL_HOME}/.cache}"
XDG_DATA_HOME="${XDG_DATA_HOME:-${REAL_HOME}/.local/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-${REAL_HOME}/.local/state}"
FONTCONFIG_HOME="${XDG_CONFIG_HOME}/fontconfig"
WECHAT_HOST_HOME="${XDG_DATA_HOME}/wechat/home"
WECHAT_CONFIG_HOME="${WECHAT_HOST_HOME}/.config"
WECHAT_CACHE_HOME="${WECHAT_HOST_HOME}/.cache"
WECHAT_DATA_HOME="${WECHAT_HOST_HOME}/.local/share"
WECHAT_STATE_HOME="${WECHAT_HOST_HOME}/.local/state"
WECHAT_FLAGS_FILE="${XDG_CONFIG_HOME}/wechat-flags.conf"
WECHAT_BWRAP_FLAGS_FILE="${XDG_CONFIG_HOME}/wechat-bwrap-flags.conf"
WECHAT_DOWNLOAD_DIR="${WECHAT_DOWNLOAD_DIR:-$(resolve_download_dir)}"
if [[ "${WECHAT_DOWNLOAD_DIR%/}" == "${REAL_HOME}" ]]; then
    WECHAT_DOWNLOAD_DIR="${REAL_HOME}/Downloads"
fi

declare -a wechat_user_flags=()
declare -a bwrap_flags=()

read_config_flags "${WECHAT_FLAGS_FILE}" wechat_user_flags
read_bwrap_flags "${WECHAT_BWRAP_FLAGS_FILE}" bwrap_flags

GCC_LIB_PATH="$(gcc_runtime_path)"

if "${EBUILD_WAYLAND}" && [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-wayland;xcb}"
    QT_IM_MODULE=text-input-unstable-v3
else
    QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-xcb}"
fi

require_path /etc/localtime
require_path /etc/machine-id
require_path /etc/resolv.conf
require_path "${USER_RUN_DIR}"
require_path /opt/wechat/wechat

install -d \
    "${WECHAT_HOST_HOME}" \
    "${WECHAT_CONFIG_HOME}" \
    "${WECHAT_CACHE_HOME}" \
    "${WECHAT_DATA_HOME}" \
    "${WECHAT_STATE_HOME}"

if [[ -n "${WECHAT_DOWNLOAD_DIR}" ]]; then
    install -d "${WECHAT_DOWNLOAD_DIR}"
fi

declare -a bwrap_cmd=(
    bwrap
    --new-session
    --cap-drop ALL
    --unshare-user-try
    --unshare-pid
    --unshare-cgroup-try
    --ro-bind /usr /usr
    --ro-bind /bin /bin
    --ro-bind /lib /lib
    --ro-bind /lib64 /lib64
    --ro-bind /opt/wechat /opt/wechat
    --ro-bind /etc/machine-id /etc/machine-id
    --ro-bind /etc/resolv.conf /etc/resolv.conf
    --ro-bind /etc/localtime /etc/localtime
    --ro-bind /etc/passwd /etc/passwd
    --ro-bind /etc/nsswitch.conf /etc/nsswitch.conf
    --ro-bind-try /etc/fonts /etc/fonts
    --ro-bind-try /run/systemd/userdb /run/systemd/userdb
    --proc /proc
    --dev-bind /dev /dev
    --ro-bind /sys /sys
    --tmpfs /sys/devices/virtual
    --dev-bind /tmp /tmp
    --dev-bind /run/dbus /run/dbus
    --bind "${USER_RUN_DIR}" "${USER_RUN_DIR}"
    --bind "${WECHAT_HOST_HOME}" "${WECHAT_HOST_HOME}"
    --bind-try "${WECHAT_DOWNLOAD_DIR}" "${WECHAT_DOWNLOAD_DIR}"
    --ro-bind /opt/wechat/xdg-open.sh /usr/bin/xdg-open
    --ro-bind-try /usr/bin/xdg-open /run/host/usr/bin/xdg-open
    --ro-bind-try "${XAUTHORITY}" "${XAUTHORITY}"
    --ro-bind-try "${FONTCONFIG_HOME}" "${WECHAT_CONFIG_HOME}/fontconfig"
    --ro-bind-try "${XDG_DATA_HOME}/fonts" "${WECHAT_DATA_HOME}/fonts"
    --ro-bind-try "${REAL_HOME}/.fonts" "${WECHAT_HOST_HOME}/.fonts"
    --ro-bind-try "${REAL_HOME}/.icons" "${REAL_HOME}/.icons"
    --ro-bind-try "${REAL_HOME}/.local/share/.icons" "${REAL_HOME}/.local/share/.icons"
    --ro-bind-try "${XDG_CONFIG_HOME}/gtk-3.0" "${XDG_CONFIG_HOME}/gtk-3.0"
    --ro-bind-try "${XDG_CONFIG_HOME}/dconf" "${XDG_CONFIG_HOME}/dconf"
    --bind-try "${REAL_HOME}/.pki" "${REAL_HOME}/.pki"
    --setenv HOME "${WECHAT_HOST_HOME}"
    --setenv XDG_CONFIG_HOME "${WECHAT_CONFIG_HOME}"
    --setenv XDG_CACHE_HOME "${WECHAT_CACHE_HOME}"
    --setenv XDG_DATA_HOME "${WECHAT_DATA_HOME}"
    --setenv XDG_STATE_HOME "${WECHAT_STATE_HOME}"
    --setenv XDG_DOWNLOAD_DIR "${WECHAT_DOWNLOAD_DIR}"
    --setenv QT_AUTO_SCREEN_SCALE_FACTOR 1
    --setenv QT_QPA_PLATFORM "${QT_QPA_PLATFORM}"
    --setenv GTK_USE_PORTAL 1
)

if [[ -n "${QT_IM_MODULE:-}" ]]; then
    bwrap_cmd+=( --setenv QT_IM_MODULE "${QT_IM_MODULE}" )
fi

if [[ -n "${GCC_LIB_PATH}" ]]; then
    bwrap_cmd+=( --setenv LD_LIBRARY_PATH "${GCC_LIB_PATH}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}" )
elif [[ -n "${LD_LIBRARY_PATH:-}" ]]; then
    bwrap_cmd+=( --setenv LD_LIBRARY_PATH "${LD_LIBRARY_PATH}" )
fi

bwrap_cmd+=( "${bwrap_flags[@]}" )
bwrap_cmd+=( /opt/wechat/wechat )
bwrap_cmd+=( "${wechat_user_flags[@]}" )
bwrap_cmd+=( "$@" )

exec "${bwrap_cmd[@]}"

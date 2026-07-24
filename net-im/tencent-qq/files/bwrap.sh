#!/bin/bash

QQ_HOTUPDATE_VERSION="__CURRENT_VER__"

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
QQ_APP_DIR="${XDG_CONFIG_HOME}/QQ"
QQ_HOTUPDATE_DIR="${QQ_APP_DIR}/versions"

# 从 flags 文件中加载用户参数
declare -a USER_BWRAP_FLAGS
if [[ -f "${XDG_CONFIG_HOME}/qq-bwrap-flags.conf" ]]; then
    mapfile -t USER_BWRAP_FLAGS <<<"$(grep -v '^#' "${XDG_CONFIG_HOME}/qq-bwrap-flags.conf")"
    echo "User bubblewrap flags:" "${USER_BWRAP_FLAGS[@]}"
fi

declare -a USER_QQ_FLAGS
if [[ -f "${XDG_CONFIG_HOME}/qq-flags.conf" ]]; then
    mapfile -t USER_QQ_FLAGS <<<"$(grep -v '^#' "${XDG_CONFIG_HOME}/qq-flags.conf")"
    echo "User QQ flags:" "${USER_QQ_FLAGS[@]}"
fi

# 设置下载文件夹
if [ -z "${QQ_DOWNLOAD_DIR}" ]; then
    if [ -z "${XDG_DOWNLOAD_DIR}" ]; then
        XDG_DOWNLOAD_DIR="$(xdg-user-dir DOWNLOAD)"
    fi
    QQ_DOWNLOAD_DIR="${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"
fi

# 当下载目录为 ~ 时，自动使用 ~/Downloads
if [ "${QQ_DOWNLOAD_DIR%*/}" == "${HOME}" ]; then
    QQ_DOWNLOAD_DIR="${HOME}/Downloads"
fi

# 安装当前版本
HOTUPDATE_VERSION_DIR="${QQ_HOTUPDATE_DIR}/${QQ_HOTUPDATE_VERSION}"
install -d "${QQ_HOTUPDATE_DIR}"
if [ ! -d "${HOTUPDATE_VERSION_DIR}" ] && [ ! -L "${HOTUPDATE_VERSION_DIR}" ]; then
    ln -sfd "/opt/QQ/resources/app" "${HOTUPDATE_VERSION_DIR}"
fi

# 处理旧版本
rm -rf "${QQ_HOTUPDATE_DIR}/"**".zip"
is_hotupdated_version=0 # 正在运行的版本是否经过热更新？

find "${QQ_HOTUPDATE_DIR}/"*[-_]* -maxdepth 1 -type "d,l" | while read path; do
    this_version="$(basename "$path")"
    if [ "$(/opt/QQ/workarounds/vercmp.sh "${this_version}" lt "${QQ_HOTUPDATE_VERSION//_/-}")" == "true" ]; then
        # 这个版本小于当前版本，删除之
        echo "rm $this_version"
        rm -rf "$path"
    else
        is_hotupdated_version=1
    fi
done

if [ "$is_hotupdated_version" == "0" ]; then
    cp "/opt/QQ/workarounds/config.json" "${QQ_HOTUPDATE_DIR}/config.json"
fi

# 移除无用崩溃报告和日志
if [[ -f "${QQ_APP_DIR}/crash_files" ]]; then
    rm "${QQ_APP_DIR}/crash_files"
fi

rm -rf "${QQ_APP_DIR}"/crash_files/* "${QQ_APP_DIR}"/Crashpad/* "${QQ_APP_DIR}"/log/*

for nt_qq_userdata in "${QQ_APP_DIR}"/nt_qq_*/nt_data; do
    rm -rf "${nt_qq_userdata}"/log/* "${nt_qq_userdata}"/log-cache/*
done

exec bwrap \
    --new-session \
    --cap-drop ALL \
    --unshare-user-try \
    --unshare-ipc \
    --unshare-pid \
    --unshare-cgroup-try \
    --dev-bind /dev /dev \
    --dev-bind /run/dbus /run/dbus \
    --ro-bind /bin /bin \
    --ro-bind /lib /lib \
    --ro-bind /lib64 /lib64 \
    --ro-bind /usr /usr \
    --ro-bind /opt /opt \
    --ro-bind /sys /sys \
    --ro-bind /etc/ld.so.cache /etc/ld.so.cache \
    --ro-bind /etc/localtime /etc/localtime \
    --ro-bind /etc/passwd /etc/passwd \
    --ro-bind /etc/machine-id /etc/machine-id \
    --ro-bind /etc/nsswitch.conf /etc/nsswitch.conf \
    --ro-bind /etc/resolv.conf /etc/resolv.conf \
    --ro-bind-try /etc/fonts /etc/fonts \
    --ro-bind-try /run/systemd/userdb /run/systemd/userdb \
    --proc /proc \
    --tmpfs /tmp \
    --tmpfs /sys/devices/virtual \
    --ro-bind /usr/lib/flatpak-xdg-utils/xdg-open /usr/bin/xdg-open \
    --bind "${QQ_APP_DIR}" "${QQ_APP_DIR}" \
    --bind "/run/user/$(id -u)" "/run/user/$(id -u)" \
    --bind-try "${QQ_DOWNLOAD_DIR}" "${QQ_DOWNLOAD_DIR}" \
    --bind-try "${HOME}/.pki" "${HOME}/.pki" \
    --ro-bind-try "${HOME}/.icons" "${HOME}/.icons" \
    --ro-bind-try "${HOME}/.local/share/.icons" "${HOME}/.local/share/.icons" \
    --ro-bind-try "${XAUTHORITY:-$HOME/.Xauthority}" "${XAUTHORITY:-$HOME/.Xauthority}" \
    --ro-bind-try "${XDG_CONFIG_HOME}/gtk-3.0" "${XDG_CONFIG_HOME}/gtk-3.0" \
    --ro-bind-try "${XDG_CONFIG_HOME}/dconf" "${XDG_CONFIG_HOME}/dconf" \
    --ro-bind-try "${XDG_CONFIG_HOME}/fontconfig" "${XDG_CONFIG_HOME}/fontconfig" \
    --setenv IBUS_USE_PORTAL 1 \
    "${USER_BWRAP_FLAGS[@]}" \
    /opt/QQ/qq "${USER_QQ_FLAGS[@]}" "$@"

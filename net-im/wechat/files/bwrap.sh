#!/bin/bash

set -euo pipefail

USER_RUN_DIR="/run/user/$(id -u)"
XAUTHORITY="${XAUTHORITY:-${HOME}/.Xauthority}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"

export XDG_DOWNLOAD_DIR="${XDG_DOWNLOAD_DIR:-$(xdg-user-dir DOWNLOAD)}"
if [[ "${XDG_DOWNLOAD_DIR%*/}" == "${HOME}" ]]; then
  export XDG_DOWNLOAD_DIR="${HOME}/Downloads"
fi

if [[ ! -e "${XDG_CONFIG_HOME}/wechat" ]]; then
  install -d "${XDG_CONFIG_HOME}/wechat"
fi

if [[ ! -e "${XDG_CONFIG_HOME}/wechat/.xwechat" && ! -e "${XDG_CONFIG_HOME}/wechat/xwechat_files" ]]; then
  if [[ -e "${XDG_DATA_HOME}/wechat/home/.xwechat" && -e "${XDG_DATA_HOME}/wechat/home/xwechat_files" ]]; then
    echo Merging the old data directories from \$XDG_DATA_HOME...
    mv -v "${XDG_DATA_HOME}/wechat/home/.xwechat" "${XDG_CONFIG_HOME}/wechat/.xwechat"
    mv -v "${XDG_DATA_HOME}/wechat/home/xwechat_files" "${XDG_CONFIG_HOME}/wechat/xwechat_files"
  elif [[ -e "${HOME}/.xwechat" && -e "${HOME}/xwechat_files" ]]; then
    echo Merging the data directories from \$HOME...
    mv -v "${HOME}/.xwechat" "${XDG_CONFIG_HOME}/wechat/.xwechat"
    mv -v "${HOME}/xwechat_files" "${XDG_CONFIG_HOME}/wechat/xwechat_files"
  fi
fi

if [[ -z "${QT_QPA_PLATFORM:-}" ]]; then
  if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    export QT_QPA_PLATFORM="wayland;xcb"
  else
    export QT_QPA_PLATFORM="xcb"
  fi
fi

declare -a user_bwrap_flags
if [[ -f "${XDG_CONFIG_HOME}/wechat-bwrap-flags.conf" ]]; then
  mapfile -t user_bwrap_flags < <(grep -v '^#' "${XDG_CONFIG_HOME}/wechat-bwrap-flags.conf")
  echo "User bubblewrap flags:" "${user_bwrap_flags[@]}"
fi

declare -a user_wechat_flags
if [[ -f "${XDG_CONFIG_HOME}/wechat-flags.conf" ]]; then
  mapfile -t user_wechat_flags < <(grep -v '^#' "${XDG_CONFIG_HOME}/wechat-flags.conf")
  echo "User WeChat flags:" "${user_wechat_flags[@]}"
fi

exec bwrap \
  --new-session \
  --cap-drop ALL \
  --unshare-user-try \
  --unshare-ipc \
  --unshare-pid \
  --unshare-cgroup-try \
  --dev-bind /dev /dev \
  --dev-bind /run/dbus /run/dbus \
  --ro-bind /usr /usr \
  --ro-bind /bin /bin \
  --ro-bind /lib /lib \
  --ro-bind /lib64 /lib64 \
  --ro-bind /sys /sys \
  --ro-bind /etc/ld.so.cache /etc/ld.so.cache \
  --ro-bind /etc/localtime /etc/localtime \
  --ro-bind /etc/passwd /etc/passwd \
  --ro-bind /etc/resolv.conf /etc/resolv.conf \
  --ro-bind /etc/machine-id /etc/machine-id \
  --ro-bind /etc/nsswitch.conf /etc/nsswitch.conf \
  --ro-bind-try /etc/fonts /etc/fonts \
  --ro-bind-try /run/systemd/userdb /run/systemd/userdb \
  --proc /proc \
  --tmpfs /tmp \
  --tmpfs /sys/devices/virtual \
  --ro-bind /usr/lib/flatpak-xdg-utils/xdg-open /usr/bin/xdg-open \
  --ro-bind /opt/wechat /opt/wechat \
  --bind "${USER_RUN_DIR}" "${USER_RUN_DIR}" \
  --bind "${XDG_CONFIG_HOME}/wechat" "${XDG_CONFIG_HOME}/wechat" \
  --bind-try "${HOME}/.pki" "${XDG_CONFIG_HOME}/wechat/.pki" \
  --bind-try "${XDG_DOWNLOAD_DIR}" "${XDG_DOWNLOAD_DIR}" \
  --ro-bind-try "${HOME}/.fonts" "${XDG_CONFIG_HOME}/wechat/.fonts" \
  --ro-bind-try "${HOME}/.icons" "${XDG_CONFIG_HOME}/wechat/.icons" \
  --ro-bind-try "${XAUTHORITY}" "${XAUTHORITY}" \
  --ro-bind-try "${XDG_CONFIG_HOME}/dconf" "${XDG_CONFIG_HOME}/dconf" \
  --ro-bind-try "${XDG_CONFIG_HOME}/fontconfig" "${XDG_CONFIG_HOME}/fontconfig" \
  --ro-bind-try "${XDG_CONFIG_HOME}/gtk-3.0" "${XDG_CONFIG_HOME}/gtk-3.0" \
  --ro-bind-try "${XDG_CONFIG_HOME}/pulse" "${XDG_CONFIG_HOME}/pulse" \
  --ro-bind-try "${XDG_DATA_HOME}/icons" "${XDG_DATA_HOME}/icons" \
  --ro-bind-try "${XDG_DATA_HOME}/fonts" "${XDG_DATA_HOME}/fonts" \
  --setenv HOME "${XDG_CONFIG_HOME}/wechat" \
  --setenv QT_AUTO_SCREEN_SCALE_FACTOR 1 \
  --setenv GTK_USE_PORTAL 1 \
  "${user_bwrap_flags[@]}" \
  /opt/wechat/wechat "${user_wechat_flags[@]}" "$@"

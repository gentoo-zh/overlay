#!/bin/bash

set -euo pipefail

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"

if [[ ! -e "${HOME}/.xwechat" && ! -e "${HOME}/xwechat_files" ]]; then
  if [[ -e "${XDG_DATA_HOME}/wechat/home/.xwechat" && -e "${XDG_DATA_HOME}/wechat/home/xwechat_files" ]]; then
    echo Merging the old data directories from \$XDG_DATA_HOME...
    mv -v "${XDG_DATA_HOME}/wechat/home/.xwechat" "${HOME}/.xwechat"
    mv -v "${XDG_DATA_HOME}/wechat/home/xwechat_files" "${HOME}/xwechat_files"
  elif [[ -e "${XDG_CONFIG_HOME}/wechat/.xwechat" && -e "${XDG_CONFIG_HOME}/wechat/xwechat_files" ]]; then
    echo Merging the data directories from \$XDG_CONFIG_HOME...
    mv -v "${XDG_CONFIG_HOME}/wechat/.xwechat" "${HOME}/.xwechat"
    mv -v "${XDG_CONFIG_HOME}/wechat/xwechat_files" "${HOME}/xwechat_files"
  fi
fi

export QT_AUTO_SCREEN_SCALE_FACTOR=1
export GTK_USE_PORTAL=1

if [[ -z "${QT_QPA_PLATFORM:-}" ]]; then
  if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    export QT_QPA_PLATFORM="wayland;xcb"
  else
    export QT_QPA_PLATFORM="xcb"
  fi
fi

declare -a user_wechat_flags
if [[ -f "${XDG_CONFIG_HOME}/wechat-flags.conf" ]]; then
  mapfile -t user_wechat_flags < <(grep -v '^#' "${XDG_CONFIG_HOME}/wechat-flags.conf")
  echo "User WeChat flags:" "${user_wechat_flags[@]}"
fi

exec /opt/wechat/wechat "${user_wechat_flags[@]}" "$@"

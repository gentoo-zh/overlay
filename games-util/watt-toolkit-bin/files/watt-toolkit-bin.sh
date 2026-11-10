#!/bin/sh
# Installed as Steam++.sh in the application directory, and linked as
# /usr/bin/watt-toolkit. The program itself runs Steam++.sh with pkexec for
# privileged work, so this file has to stay on that path.

appdir=/usr/lib/watt-toolkit

DOTNET_ROOT="${appdir}/dotnet"
export DOTNET_ROOT
exec "${DOTNET_ROOT}/dotnet" exec "${appdir}/Steam++.dll" "$@"

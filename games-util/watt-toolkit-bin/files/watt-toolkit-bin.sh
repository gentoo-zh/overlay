#!/bin/sh
# Installed as Steam++.sh in the application directory, and linked as
# /usr/bin/watt-toolkit. The program itself runs Steam++.sh with pkexec for
# privileged work, so this file has to stay on that path.

appdir=/usr/lib/watt-toolkit

for root in /opt/dotnet-sdk-bin-10.0 /usr/lib64/dotnet-sdk-10.0 /usr/lib/dotnet-sdk-10.0; do
	[ -x "${root}/dotnet" ] || continue
	DOTNET_ROOT="${root}"
	export DOTNET_ROOT
	exec "${root}/dotnet" exec "${appdir}/Steam++.dll" "$@"
done

exec dotnet exec "${appdir}/Steam++.dll" "$@"

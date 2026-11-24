#!/bin/sh
# Installed as Steam++.sh in the application directory, and linked as
# /usr/bin/watt-toolkit. The program runs Steam++.sh to restart itself and
# with pkexec to import its certificate, so this file has to stay on that path.

exec /usr/lib/watt-toolkit/Steam++ "$@"

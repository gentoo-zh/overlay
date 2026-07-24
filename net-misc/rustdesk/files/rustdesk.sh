#!/bin/sh

cd /usr/share/rustdesk || exit 1
exec ./rustdesk "$@"

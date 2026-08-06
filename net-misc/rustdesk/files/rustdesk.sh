#!/bin/sh

cd /usr/lib/rustdesk || exit 1
exec ./rustdesk "$@"

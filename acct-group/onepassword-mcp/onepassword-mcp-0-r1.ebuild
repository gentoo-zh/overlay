# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-group

# The 1Password desktop app rejects a client whose group has a GID below
# GID_MIN, so assign one instead of letting it be allocated as a system GID.
ACCT_GROUP_ID=26755
# The previous ACCT_GROUP_ID=-1 created a system group; remove it with
# "groupdel onepassword-mcp" and then rerun emerge.
ACCT_GROUP_ENFORCE_ID=yes

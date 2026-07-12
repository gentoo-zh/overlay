# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Virtual to depend on any Distribution Kernel"

SLOT="0/${PV}"
KEYWORDS="~amd64"

RDEPEND="
	|| (
		~sys-kernel/xanmod-kernel-${PV}
	)"

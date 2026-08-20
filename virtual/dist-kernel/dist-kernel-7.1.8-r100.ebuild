# Copyright 2021-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Virtual to depend on any Distribution Kernel"
SLOT="0/${PVR}"
KEYWORDS="~amd64"

RDEPEND="
	|| (
		~sys-kernel/gentoo-cjk-kernel-bin-${PV}
		~sys-kernel/gentoo-cjk-kernel-${PV}
	)
"

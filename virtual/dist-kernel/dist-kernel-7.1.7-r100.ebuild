# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Virtual to depend on any Distribution Kernel"

SLOT="0/${PV}"
KEYWORDS="~amd64"

# The prebuilt package comes first: || takes the leftmost that can be
# satisfied, and installing this virtual should not compile a kernel.
RDEPEND="
	|| (
		~sys-kernel/gentoo-cjk-kernel-bin-${PV}
		~sys-kernel/gentoo-cjk-kernel-${PV}
	)"

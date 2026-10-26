# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="LoongArch old-world ABI compatibility layer from AOSC OS"
HOMEPAGE="https://liblol.aosc.io"

# liblol itself is licensed under GPL-2 according to the AOSC maintainers.
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* ~loong"

RDEPEND="
	~app-emulation/liblol-glibc-${PV}
	~app-emulation/liblol-libxcrypt-${PV}
"
PDEPEND="app-emulation/la-ow-syscall"

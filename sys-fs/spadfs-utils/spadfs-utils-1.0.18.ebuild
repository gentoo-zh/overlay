# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit toolchain-funcs

DESCRIPTION="Filesystem Tools for SpadFS"
HOMEPAGE="http://www.jikos.cz/~mikulas/spadfs/"
SRC_URI="http://www.jikos.cz/~mikulas/spadfs/download/spadfs-${PV}.tar.gz"

S="${WORKDIR}/spadfs-${PV}"
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="bindist mirror"

src_compile() {
	emake SPADFS_CC="$(tc-getCC)" mkspadfs spadfsck
}

src_install() {
	dobin mkspadfs
	dobin spadfsck
}

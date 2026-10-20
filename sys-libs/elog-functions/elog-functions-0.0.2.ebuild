# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit multilib

DESCRIPTION="Compatibility functions for the log e* functions of OpenRC"
HOMEPAGE="http://xochitl.matem.unam.mx/~canek/gentoo-systemd-only/index.html"

S="${WORKDIR}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

RDEPEND="app-shells/bash"

src_install() {
	insinto /usr/$(get_abi_LIBDIR)/misc
	doins "${FILESDIR}/${PN}.sh"
}

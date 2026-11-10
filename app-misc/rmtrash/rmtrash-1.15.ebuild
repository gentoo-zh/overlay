# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="trash-put made compatible to GNUs rm and rmdir"
HOMEPAGE="https://github.com/PhrozenByte/rmtrash"
SRC_URI="https://github.com/PhrozenByte/rmtrash/archive/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="app-misc/trash-cli"

src_install() {
	insinto /usr/bin
	insopts -m755
	doins rmtrash
	doins rmdirtrash
}

pkg_postinst() {
	elog "It is suggested to add following code into ~/.bashrc:"
	elog "--------------------------------------------------------------------"
	elog "		alias rm='rmtrash'"
	elog "		alias rmdir='rmdirtrash'"
	elog "		alias sudo='sudo '"
	elog "--------------------------------------------------------------------"
	elog "see https://github.com/PhrozenByte/rmtrash for more information"
}

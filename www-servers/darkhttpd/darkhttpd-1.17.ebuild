# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A small, static webserver"
HOMEPAGE="https://unix4lyfe.org/darkhttpd/"
SRC_URI="https://github.com/emikulic/darkhttpd/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="ISC"
SLOT="0"
KEYWORDS="~amd64"

src_install() {
	dobin "${PN}"
	dodoc README.md
}

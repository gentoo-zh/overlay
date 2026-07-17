# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="GNU groff wrapper allowing UTF-8 input"
HOMEPAGE="https://www.haible.de/bruno/packages-groff-utf8.html"
SRC_URI="https://www.haible.de/bruno/gnu/${PN}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${PN}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=">=sys-apps/groff-1.18.1"

src_prepare() {
	default
	sed -i -e '/^CFLAGS/d' Makefile || die
	sed -i -e '/^LDFLAGS/d' Makefile || die
	sed -i -e '/^CPPFLAGS/d' Makefile || die
	sed -i -e '/^CC/d' Makefile || die
}

src_install() {
	emake install DESTDIR="${D}" PREFIX=/usr CFLAGS="${CFLAGS}" || die "make install failed"
}

pkg_postinst() {
	sed	's/^NROFF.*\/usr\/bin\/nroff -mandoc/NROFF\t\t\/usr\/bin\/groff-utf8 -Tutf8 -c -mandoc/' -i /etc/man.conf || die
}

pkg_postrm(){
	sed	's/groff-utf8 -Tutf8 -c -mandoc/nroff -mandoc/g' -i /etc/man.conf || die
}

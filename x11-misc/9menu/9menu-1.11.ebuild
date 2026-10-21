# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Create X menus from the shell"
HOMEPAGE="https://packages.debian.org/source/sid/9menu"
SRC_URI="https://github.com/arnoldrobbins/9menu/archive/refs/tags/${PN}-release-${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${PN}-release-${PV}"
LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

RDEPEND="x11-libs/libX11"

src_prepare() {
	default
	eapply "${FILESDIR}/fix-ignore-cflags-and-ldflags.patch"
}

src_compile() {
	emake -f Makefile.noimake || die "emake error"
}

src_install() {
	dobin 9menu
	doman "${PN}.1"
	dodoc README
}

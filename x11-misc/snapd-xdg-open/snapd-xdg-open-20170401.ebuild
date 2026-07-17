# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools

DESCRIPTION="Software for opening links from snaps in desktop"
HOMEPAGE="https://github.com/canonical/snapd-xdg-open"
EGIT_COMMIT="6fed3570066ea93598e8091bf749352a02d482ad"
SRC_URI="https://github.com/canonical/snapd-xdg-open/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${PN}-${EGIT_COMMIT}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~loong"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf --prefix=/usr \
		--libexecdir=/usr/lib/"${PN}"
}

src_install() {
	default
	exeinto /usr/lib/"${PN}"
	doexe src/xdg-open
}

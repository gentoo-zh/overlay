# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg unpacker

DESCRIPTION="Platform for API design, debugging, testing, and documentation"
HOMEPAGE="https://apifox.com/"
SRC_URI="
	amd64? ( https://file-assets.apifox.com/download/Apifox-linux-latest.zip -> ${P}-amd64.zip )
"

S="${WORKDIR}"
LICENSE="all-rights-reserved"

SLOT="0"
KEYWORDS="~amd64"

RESTRICT="bindist mirror strip"

RDEPEND="sys-fs/fuse:0"
BDEPEND="app-arch/unzip"

src_install() {
	into /opt/apifox
	dobin "${S}/Apifox.AppImage"
	domenu "${FILESDIR}/apifox.desktop"
	doicon -s scalable "${FILESDIR}/apifox.svg"
}

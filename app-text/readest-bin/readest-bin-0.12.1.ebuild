# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

MY_PN="${PN%-bin}"

DESCRIPTION="A modern, feature-rich ebook reader"
HOMEPAGE="https://readest.com/ https://github.com/readest/readest"
URI_PREFIX="https://github.com/readest/readest/releases/download/v${PV}/Readest_${PV}"
SRC_URI="
	amd64? ( ${URI_PREFIX}_amd64.AppImage -> ${P}_amd64.AppImage )
"

S="${WORKDIR}"
LICENSE="AGPL-3"

SLOT="0"
KEYWORDS="~amd64"

RESTRICT="strip"
QA_PREBUILT="usr/bin/${MY_PN}"

RDEPEND="sys-fs/fuse:0"

src_unpack() {
	cp "${DISTDIR}/${P}_amd64.AppImage" "${MY_PN}" || die
	chmod +x "${MY_PN}" || die
	./"${MY_PN}" --appimage-extract >/dev/null || die
}

src_install() {
	dobin "${MY_PN}"
	domenu squashfs-root/Readest.desktop
	doicon -s 256 squashfs-root/readest.png
}

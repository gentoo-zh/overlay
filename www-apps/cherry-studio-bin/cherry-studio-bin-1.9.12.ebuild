# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="Cherry Studio is a desktop client that supports for multiple LLM providers"
HOMEPAGE="https://github.com/CherryHQ/cherry-studio"
URL_PREFIX="https://github.com/CherryHQ/cherry-studio/releases/download/v${PV}/Cherry-Studio-${PV}"
SRC_URI="
	amd64? ( ${URL_PREFIX}-x86_64.AppImage -> ${P}-x86_64.AppImage )
	arm64? ( ${URL_PREFIX}-arm64.AppImage -> ${P}-arm64.AppImage )
"

S="${WORKDIR}"
LICENSE="Cherry-Studio"

SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="sys-fs/fuse:0"

RESTRICT="strip"

src_unpack() {
	if use amd64; then
		cp "${DISTDIR}/${P}-x86_64.AppImage" cherry-studio || die
	elif use arm64; then
		cp "${DISTDIR}/${P}-arm64.AppImage" cherry-studio || die
	fi
}

src_install() {
	dobin cherry-studio
	domenu "${FILESDIR}/cherry-studio.desktop"
	doicon -s scalable "${FILESDIR}/cherry-studio.svg"
}

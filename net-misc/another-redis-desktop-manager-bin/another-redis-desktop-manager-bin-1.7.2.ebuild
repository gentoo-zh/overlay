# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="A faster, better and more stable Redis desktop manager [GUI client]"
HOMEPAGE="https://github.com/qishibo/AnotherRedisDesktopManager"
SRC_URI="https://github.com/qishibo/AnotherRedisDesktopManager/releases/download/v${PV}/Another-Redis-Desktop-Manager-linux-${PV}-x86_64.AppImage -> ${P}.AppImage"
S="${WORKDIR}"
LICENSE="MIT"

SLOT="0"
KEYWORDS="~amd64"

RESTRICT="strip"

RDEPEND="sys-fs/fuse:0"

src_unpack() {
	cp "${DISTDIR}/${P}.AppImage" another-redis-desktop-manager || die
}

src_install() {
	dobin another-redis-desktop-manager
	domenu "${FILESDIR}/another-redis-desktop-manager.desktop"
	doicon -s scalable "${FILESDIR}/another-redis-desktop-manager.svg"
}

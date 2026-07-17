# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Based on https://github.com/BlueManCZ/edgets/tree/master/net-im/kotatogram-desktop-bin

EAPI=8

inherit desktop unpacker

DESCRIPTION="Telegram Desktop fork with wide messages, local folders, square avatars"
HOMEPAGE="https://thatcat.space/kotatogram/"

SRC_URI="https://github.com/kotatogram/kotatogram-desktop/releases/download/k${PV}/${PV}-linux.tar.xz -> ${P}.tar.xz"

S="${WORKDIR}/Kotatogram"

LICENSE="GPL-3"

SLOT="0"

KEYWORDS="~amd64"

RESTRICT="strip"

DEPEND="
	sys-fs/fuse:0
	x11-misc/xdg-utils"

QA_PREBUILT="*"

src_prepare() {
	eapply_user
}

src_install() {
	newbin Kotatogram kotatogram

	domenu "${FILESDIR}"/kotatogram-bin.desktop
}

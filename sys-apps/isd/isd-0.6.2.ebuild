# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="isd (interactive systemd) — a better way to work with systemd units"
HOMEPAGE="https://github.com/kainctl/isd"
SRC_URI="https://github.com/kainctl/isd/releases/download/v${PV}/isd.x86_64-linux.AppImage -> ${P}.AppImage"

S="${WORKDIR}"
LICENSE="GPL-3"

SLOT="0"
KEYWORDS="-* ~amd64"

RESTRICT="strip"

RDEPEND="
	|| (
		sys-apps/systemd
		sys-apps/systemd-utils
	)
	sys-fs/fuse:0
"

src_unpack() {
	cp "${DISTDIR}/${P}.AppImage" isd || die
}

src_install() {
	dobin isd
}

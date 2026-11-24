# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="Desktop music player with a plugin system"
HOMEPAGE="https://github.com/qier222/YesPlayMusic"
SRC_URI="https://github.com/qier222/YesPlayMusic/releases/download/v${PV}/YesPlayMusic-${PV}-linux-x64.tar.gz"

S="${WORKDIR}/YesPlayMusic-${PV}-linux-x64"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~amd64"

RESTRICT="strip"

RDEPEND="
	sys-libs/glibc
	app-accessibility/at-spi2-core:2
	dev-libs/glib:2
	dev-libs/wayland
	media-libs/fontconfig
	media-libs/harfbuzz
	media-libs/libepoxy
	media-video/mpv:0[libmpv]
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/pango
"

QA_PREBUILT="
	opt/YesPlayMusic/yesplaymusic
	opt/YesPlayMusic/lib/*.so
"

src_install() {
	insinto /opt/YesPlayMusic
	doins -r data lib
	exeinto /opt/YesPlayMusic
	doexe yesplaymusic
	dosym -r /opt/YesPlayMusic/yesplaymusic /usr/bin/yesplaymusic

	domenu yesplaymusic.desktop
	newicon -s 512 yesplaymusic.png yesplaymusic.png
}

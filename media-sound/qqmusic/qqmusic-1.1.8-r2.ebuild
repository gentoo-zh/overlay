# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

qqmusic_src_uri() {
	printf "https://qqmusic-sign.qqmusic-sign-worker.workers.dev/"
	printf "https://c.y.qq.com/cgi-bin/file_redirect.fcg?bid=dldir&file=ecosfile_plink%%2Fmusic_clntupate%%2Flinux%%2Fother%%2Fqqmusic_${PV}_amd64.deb"
	printf " -> ${P}_amd64.deb"
}

DESCRIPTION="Tencent QQ Music, converted from .deb package"
HOMEPAGE="https://y.qq.com/"
# dldir.y.qq.com may only serve this file in mainland China; elsewhere it
# returns 403, so download the file manually and place it in DISTDIR.
SRC_URI="$(qqmusic_src_uri)"

S="${WORKDIR}"

LICENSE="QQMusic-EULA"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror strip"

RDEPEND="
	app-accessibility/at-spi2-core:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	net-print/cups
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-libs/pango
"

src_install() {
	insinto /opt
	doins -r opt/*
	fperms +x /opt/qqmusic/{qqmusic,chrome-sandbox,crashpad_handler,libEGL.so,libGLESv2.so,libffmpeg.so,libvk_swiftshader.so,swiftshader/libEGL.so,swiftshader/libGLESv2.so}
	newbin "${FILESDIR}"/qqmusic.sh qqmusic
	domenu "${FILESDIR}"/qqmusic.desktop
	for i in 16 32 64 128 256; do
		doicon -s $i usr/share/icons/hicolor/"$i"x"$i"/apps/qqmusic.png
	done
	gzip -d usr/share/doc/qqmusic/changelog.gz || die
	dodoc usr/share/doc/qqmusic/changelog
}

# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit unpacker xdg

DESCRIPTION="Tencent videos"
HOMEPAGE="https://v.qq.com/download.html#linux"
SRC_URI="https://dldir1.qq.com/qqtv/linux/Tenvideo_universal_${PV}_amd64.deb"

S="${WORKDIR}"

LICENSE="tenvideo-privacy"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="strip mirror bindist"

RDEPEND="
	app-accessibility/at-spi2-core
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
	x11-libs/libXScrnSaver
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXtst
	x11-libs/libxcb
	x11-libs/pango
"

QA_PREBUILT="*"

src_install() {
	sed -i 's/腾讯视频/tenvideo/g' "${S}"/usr/share/applications/TencentVideo.desktop || die
	insinto /usr/share
	doins -r "${S}"/usr/share/{applications,icons}

	insinto /opt/tenvideo
	doins -r "${S}"/opt/腾讯视频/*

	fperms 0755 /opt/tenvideo/TencentVideo
	fperms 4755 /opt/tenvideo/chrome-sandbox
}

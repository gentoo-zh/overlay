# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

DESCRIPTION="A third party music player for Netease Music"
HOMEPAGE="https://github.com/qier222/YesPlayMusic"
BASE_URI="https://github.com/qier222/YesPlayMusic/releases/download"
SRC_URI="
	amd64? ( ${BASE_URI}/v${PV}/${PN%-bin}_${PV}_amd64.deb )
	arm64? ( ${BASE_URI}/v${PV}/${PN%-bin}_${PV}_arm64.deb )
"

S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RESTRICT="mirror strip"

QA_PRESTRIPPED="*"

RDEPEND="
	app-accessibility/at-spi2-core:2
	app-arch/gzip
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/libxshmfence
	x11-libs/pango
"

QA_PREBUILT="
	opt/YesPlayMusic/chrome-sandbox
	opt/YesPlayMusic/libEGL.so
	opt/YesPlayMusic/libGLESv2.so
	opt/YesPlayMusic/libffmpeg.so
	opt/YesPlayMusic/libvk_swiftshader.so
	opt/YesPlayMusic/libvulkan.so.1
	opt/YesPlayMusic/swiftshader/libEGL.so
	opt/YesPlayMusic/swiftshader/libGLESv2.so
	opt/YesPlayMusic/yesplaymusic
"

src_install(){
	insinto "/opt"
	doins -r "${S}/opt/YesPlayMusic"
	for si in 16 24 32 48 64 128 256 512; do
		doicon -s ${si} usr/share/icons/hicolor/${si}x${si}/apps/${PN%-bin}.png
	done
	domenu "${FILESDIR}/${PN%-bin}.desktop"
	fperms 0755 "/opt/YesPlayMusic/yesplaymusic"
}

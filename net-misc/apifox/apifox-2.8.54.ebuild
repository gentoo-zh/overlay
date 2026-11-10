# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="Platform for API design, debugging, testing, and documentation"
HOMEPAGE="https://apifox.com/"
SRC_URI="
	amd64? ( https://file-assets.apifox.com/download/Apifox-linux-latest.zip -> ${P}-amd64.zip )
"

S="${WORKDIR}/squashfs-root"
LICENSE="all-rights-reserved"

SLOT="0"
KEYWORDS="~amd64"

RESTRICT="bindist mirror strip"

RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa[opengl]
	net-print/cups
	sys-apps/dbus
	virtual/libudev
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libnotify
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/pango
"
BDEPEND="app-arch/unzip"

QA_PREBUILT="opt/apifox/*"
REQUIRES_EXCLUDE="libdb2.so.1"

src_unpack() {
	default
	chmod +x Apifox.AppImage || die
	./Apifox.AppImage --appimage-extract > /dev/null || die
}

src_prepare() {
	default
	find . -type d -exec chmod a+rx {} + || die
}

src_install() {
	rm -r AppRun .DirIcon apifox.desktop apifox.png usr \
		resources/app.asar.unpacked/node_modules/@napi-rs/snappy-linux-x64-musl || die

	dodir /opt/apifox
	cp -r . "${ED}"/opt/apifox || die
	fperms 4711 /opt/apifox/chrome-sandbox
	dosym -r /opt/apifox/apifox /usr/bin/apifox

	domenu "${FILESDIR}/apifox.desktop"
	doicon -s scalable "${FILESDIR}/apifox.svg"
}

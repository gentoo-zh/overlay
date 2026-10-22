# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg unpacker

DESCRIPTION="Run Windows apps on Linux with seamless integration"
HOMEPAGE="https://www.winboat.app/"
SRC_URI="https://github.com/winboat-org/winboat/releases/download/v${PV}/winboat-${PV}-amd64.deb"

S="${WORKDIR}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="strip"

RDEPEND="
	app-accessibility/at-spi2-core:2
	app-containers/docker
	app-containers/docker-compose
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa
	net-misc/freerdp:3
	net-print/cups
	sys-apps/dbus
	virtual/libudev
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/pango
"

src_prepare() {
	default

	for mode in argon2 usb; do
		local pre="${S}/opt/winboat/resources/app.asar.unpacked/node_modules/${mode}/prebuilds"
		if [[ -d ${pre} ]]; then
			find "${pre}/" -mindepth 1 -maxdepth 1 ! -name "linux-x64" -type d -exec rm -rf {} + || die
			rm -f "${pre}/linux-x64/"*musl* || die
		fi
	done
}

src_install() {
	insinto /opt/winboat
	doins -r "${S}"/opt/winboat/*
	fperms +x /opt/winboat/winboat
	fperms +x /opt/winboat/chrome-sandbox
	fperms +x /opt/winboat/chrome_crashpad_handler
	domenu "${S}/usr/share/applications/winboat.desktop"
	newicon -s scalable "${S}/usr/share/icons/hicolor/scalable/apps/winboat.svg" winboat.svg
}

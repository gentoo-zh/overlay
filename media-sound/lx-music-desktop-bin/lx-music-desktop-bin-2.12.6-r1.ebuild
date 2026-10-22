# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker desktop xdg
MY_PN="lx-music-desktop"
DESCRIPTION="一个基于 electron 的音乐软件"
HOMEPAGE="https://github.com/lyswhut/lx-music-desktop"
SRC_URI="
	amd64? ( https://github.com/lyswhut/lx-music-desktop/releases/download/v${PV}/lx-music-desktop_${PV}_amd64.deb )
	arm64? ( https://github.com/lyswhut/lx-music-desktop/releases/download/v${PV}/lx-music-desktop_${PV}_arm64.deb )
"
S="${WORKDIR}"
LICENSE="Apache-2.0"
SLOT="0"
QA_PREBUILT="*"
KEYWORDS="-* ~amd64 ~arm64"
RDEPEND="
	app-accessibility/at-spi2-core:2[X]
	app-crypt/libsecret
	app-crypt/p11-kit
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/libayatana-appindicator
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	virtual/libudev
	x11-libs/cairo
	x11-libs/gtk+:3[cups]
	x11-libs/libnotify
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/libXScrnSaver
	x11-libs/pango
"
src_install() {
	insinto /opt
	doins -r opt/*
	fperms +x /opt/${MY_PN}/${MY_PN}
	dosym -r /opt/${MY_PN}/${MY_PN} /usr/bin/${MY_PN}
	gzip -d usr/share/doc/${MY_PN}/*.gz || die
	dodoc usr/share/doc/${MY_PN}/*
	doicon -s 512 usr/share/icons/hicolor/512x512/apps/lx-music-desktop.png
	domenu usr/share/applications/lx-music-desktop.desktop
}

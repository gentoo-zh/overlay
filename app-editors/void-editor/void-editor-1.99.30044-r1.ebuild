# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="Void Editor - AI Code Editor"
HOMEPAGE="https://voideditor.com"

SRC_URI="
	amd64? ( https://github.com/voideditor/binaries/releases/download/${PV}/Void-linux-x64-${PV}.tar.gz )
	arm64? ( https://github.com/voideditor/binaries/releases/download/${PV}/Void-linux-arm64-${PV}.tar.gz )
"
S="${WORKDIR}"

LICENSE="Apache-2.0 MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="mirror strip"

RDEPEND="
	app-accessibility/at-spi2-core:2
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	sys-apps/ripgrep
	virtual/libudev
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/libxkbfile
	x11-libs/pango
"

QA_PREBUILT="
	opt/void/*
"

src_install() {
	insinto /opt/void
	doins -r "${S}"/*
	fperms +x /opt/void/void
	dosym ../../opt/void/void /usr/bin/void

	domenu "${FILESDIR}"/void-editor.desktop
	doicon -s 256 "${S}/resources/app/resources/linux/code.png"
	dodoc "${S}/LICENSES.chromium.html"
}

# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

DESCRIPTION="Desktop application for the OpenCode AI coding agent"
HOMEPAGE="https://opencode.ai https://github.com/anomalyco/opencode"
SRC_URI="
	amd64? ( https://opencode.ai/files/bin/${PV}/opencode-desktop-linux-amd64.deb -> ${P}-amd64.deb )
	arm64? ( https://opencode.ai/files/bin/${PV}/opencode-desktop-linux-arm64.deb -> ${P}-arm64.deb )
	https://raw.githubusercontent.com/anomalyco/opencode/044d8b7d2e5dceef7adc6e620e53e70707b88951/LICENSE -> ${P}-LICENSE
"
S="${WORKDIR}"

LICENSE="0BSD Apache-2.0 BSD BSD-2 BlueOak-1.0.0 ISC LGPL-2.1+ MIT MPL-2.0 PSF-2"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

RDEPEND="
	app-accessibility/at-spi2-core:2
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	dev-vcs/git
	media-libs/alsa-lib
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	virtual/libudev:0
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
	x11-libs/pango
	x11-misc/xdg-utils
"

QA_PREBUILT="
	opt/${PN}/ai.opencode
	opt/${PN}/chrome-sandbox
	opt/${PN}/chrome_crashpad_handler
	opt/${PN}/libffmpeg.so
	opt/${PN}/libvk_swiftshader.so
	opt/${PN}/libvulkan.so.1
	opt/${PN}/resources/opencode-cli
	opt/${PN}/resources/app.asar.unpacked/node_modules/@lydell/node-pty-linux-*/prebuilds/linux-*/pty.node
"

src_unpack() {
	unpack_deb ${P}-${ARCH}.deb
}

src_prepare() {
	default
	# Without package-type, electron-updater disables updates outside AppImage.
	rm opt/OpenCode/resources/{app-update.yml,package-type,apparmor-profile} || die
	sed -i 's|^Exec=.*|Exec=opencode-desktop %U|' usr/share/applications/*.desktop || die
}

src_install() {
	dodir /opt/${PN}
	cp -r opt/OpenCode/. "${ED}/opt/${PN}/" || die
	fperms 4711 /opt/${PN}/chrome-sandbox
	dosym -r /opt/${PN}/ai.opencode /usr/bin/opencode-desktop

	domenu usr/share/applications/*.desktop
	insinto /usr/share/metainfo
	doins usr/share/metainfo/ai.opencode.desktop.metainfo.xml

	local size
	for size in 32 64 128; do
		doicon -s ${size} usr/share/icons/hicolor/${size}x${size}/apps/ai.opencode.png
	done
	newdoc "${DISTDIR}/${P}-LICENSE" LICENSE
}

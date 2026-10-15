# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

DESCRIPTION="Command Code desktop workspace for AI coding agents"
HOMEPAGE="https://commandcode.ai/desktop https://github.com/CommandCodeAI/desktop"
SRC_URI="
	amd64? ( https://github.com/CommandCodeAI/desktop/releases/download/v${PV}/CommandCode-${PV}-amd64.deb )
"
S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror strip"

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
	x11-libs/libnotify
	x11-libs/pango
	x11-misc/xdg-utils
"

QA_PREBUILT="
	opt/${PN}/command-code
	opt/${PN}/chrome-sandbox
	opt/${PN}/chrome_crashpad_handler
	opt/${PN}/lib*.so*
	opt/${PN}/resources/app/node_modules/@crosscopy/clipboard-linux-x64-gnu/*.node
	opt/${PN}/resources/app/node_modules/@lydell/node-pty-linux-x64/prebuilds/linux-x64/pty.node
	opt/${PN}/resources/app/node_modules/@parcel/watcher-linux-x64-glibc/watcher.node
	opt/${PN}/resources/app/node_modules/@vscode/ripgrep-linux-x64/bin/rg
"

src_prepare() {
	default

	local modules="opt/Command Code/resources/app/node_modules"
	# Electron uses glibc; foreign and musl prebuilds cannot be loaded here.
	rm -r "${modules}"/@lydell/node-pty-{darwin-*,win32-*,linux-arm64} \
		"${modules}"/@parcel/watcher-{darwin-*,win32-*,linux-arm64-*,linux-x64-musl} \
		"${modules}"/@crosscopy/clipboard-{darwin-*,win32-*,linux-arm64-gnu} || die
	# These files describe the Debian updater and its original installation path.
	rm "opt/Command Code/resources/"{app-update.yml,package-type,apparmor-profile} || die
	sed -i 's|^Exec=.*|Exec=command-code-desktop %U|' \
		usr/share/applications/command-code.desktop || die
}

src_install() {
	dodir /opt/${PN}
	cp -r "opt/Command Code/." "${ED}/opt/${PN}/" || die
	fperms 4711 /opt/${PN}/chrome-sandbox

	printf '#!/bin/sh\nexport CMD_DISABLE_AUTO_UPDATE=1\nexec "%s/opt/%s/command-code" "$@"\n' \
		"${EPREFIX}" "${PN}" > "${T}/command-code-desktop" || die
	dobin "${T}/command-code-desktop"
	domenu usr/share/applications/command-code.desktop

	local size
	for size in 16 24 32 48 64 128 256 512; do
		doicon -s ${size} usr/share/icons/hicolor/${size}x${size}/apps/command-code.png
	done
}

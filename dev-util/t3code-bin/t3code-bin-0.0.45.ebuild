# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

DESCRIPTION="Desktop control surface for local coding agents"
HOMEPAGE="https://t3.codes https://github.com/pingdotgg/t3code"
SRC_URI="
	amd64? ( https://github.com/pingdotgg/t3code/releases/download/v${PV}/T3-Code-${PV}-amd64.deb )
	arm64? ( https://github.com/pingdotgg/t3code/releases/download/v${PV}/T3-Code-${PV}-arm64.deb )
"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
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
	net-misc/openssh
	net-print/cups
	sys-apps/dbus
	>=sys-libs/glibc-2.39
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
	opt/${PN}/chrome-sandbox
	opt/${PN}/chrome_crashpad_handler
	opt/${PN}/lib*.so*
	opt/${PN}/t3code
	opt/${PN}/resources/browser-secret/t3-browser-secret
	opt/${PN}/resources/hyprland-capture/t3-hyprland-snap-shot
	opt/${PN}/resources/kde-capture/t3-kde-snap-shot
	opt/${PN}/resources/resource-monitor/t3-resource-monitor
	opt/${PN}/resources/app.asar.unpacked/node_modules/*
"

src_prepare() {
	default
	local app="opt/T3 Code (Alpha)" modules="opt/T3 Code (Alpha)/resources/app.asar.unpacked/node_modules"
	# Electron requires glibc; these musl libraries and foreign prebuilds are never loaded.
	rm -r "${modules}"/@ff-labs/fff-bin-linux-*-musl || die
	if use amd64; then
		rm -r "${modules}"/@yuuang/ffi-rs-linux-x64-musl \
			"${modules}"/node-pty/prebuilds/linux-arm64 || die
	else
		rm -r "${modules}"/node-pty/prebuilds/linux-x64 || die
	fi
	# Omit Debian updater metadata and its AppArmor profile for the original /opt path.
	rm "${app}"/resources/{app-update.yml,package-type,apparmor-profile} || die
	sed -i 's|^Exec=.*|Exec=t3code %U|' usr/share/applications/t3code.desktop || die
}

src_install() {
	dodir /opt/${PN}
	cp -r "opt/T3 Code (Alpha)/." "${ED}/opt/${PN}/" || die
	fperms 4711 /opt/${PN}/chrome-sandbox

	printf '#!/bin/sh\nexport T3CODE_DISABLE_AUTO_UPDATE=true\nexec "%s/opt/%s/t3code" "$@"\n' \
		"${EPREFIX}" "${PN}" > "${T}/t3code" || die
	dobin "${T}/t3code"
	newmenu usr/share/applications/t3code.desktop com.t3tools.T3Code.desktop

	local size
	for size in 16 22 24 32 48 64 128 256 512; do
		doicon -s ${size} usr/share/icons/hicolor/${size}x${size}/apps/t3code.png
	done
}

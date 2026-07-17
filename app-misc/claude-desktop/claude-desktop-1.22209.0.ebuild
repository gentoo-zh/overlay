# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop optfeature pax-utils unpacker xdg

DESCRIPTION="Desktop application for Claude.ai"
HOMEPAGE="https://claude.com/download"

SRC_URI="
	amd64? (
		https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_${PV}_amd64.deb
			-> ${P}-amd64.deb
	)
	arm64? (
		https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_${PV}_arm64.deb
			-> ${P}-arm64.deb
	)
"
S="${WORKDIR}"

LICENSE="Anthropic"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="bindist mirror strip"

RDEPEND="
	|| (
		sys-apps/systemd
		sys-apps/systemd-utils
	)
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-crypt/libsecret[crypt]
	app-misc/ca-certificates
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	sys-apps/xdg-desktop-portal
	sys-libs/libcap-ng
	sys-libs/libseccomp
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libnotify
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/libXtst
	x11-libs/pango
	x11-misc/xdg-utils
"

QA_PREBUILT="*"

src_install() {
	# Install the application to /opt
	dodir /opt
	mv usr/lib/claude-desktop "${ED}/opt/${PN}" || die

	# Fix chrome-sandbox permissions
	fperms 4755 "/opt/${PN}/chrome-sandbox"

	# Allow V8's JIT to run under PaX/hardened kernels
	pax-mark m "${ED}/opt/${PN}/claude-desktop"

	# Launcher on PATH
	dosym -r "/opt/${PN}/claude-desktop" /usr/bin/claude-desktop

	# Desktop entry and icons (upstream renamed it to the freedesktop app-id)
	domenu usr/share/applications/com.anthropic.Claude.desktop
	insinto /usr/share/icons
	doins -r usr/share/icons/hicolor
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "~/.claude is shared with Claude Code, so signing in may update its login state."

	optfeature "secret/keyring storage" virtual/secret-service
	optfeature "Cowork sandboxed VM support" app-emulation/qemu
}

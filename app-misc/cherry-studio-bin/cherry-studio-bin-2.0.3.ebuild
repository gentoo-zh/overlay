# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="Cherry Studio is a desktop client that supports for multiple LLM providers"
HOMEPAGE="https://github.com/CherryHQ/cherry-studio"
URL_PREFIX="https://github.com/CherryHQ/cherry-studio/releases/download/v${PV}/Cherry-Studio-${PV}"
SRC_URI="
	amd64? ( ${URL_PREFIX}-x86_64.AppImage -> ${P}-x86_64.AppImage )
	arm64? ( ${URL_PREFIX}-arm64.AppImage -> ${P}-arm64.AppImage )
"

S="${WORKDIR}"
LICENSE="AGPL-3 all-rights-reserved"

SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
IUSE="cpu_flags_x86_avx cpu_flags_x86_avx2"
REQUIRED_USE="amd64? ( cpu_flags_x86_avx cpu_flags_x86_avx2 )"

RDEPEND="
	app-accessibility/at-spi2-core:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/libevdev
	dev-libs/nspr
	dev-libs/nss
	dev-libs/wayland
	media-libs/alsa-lib
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	sys-fs/fuse:0
	virtual/libudev:0/1
	virtual/zlib
	x11-libs/cairo
	x11-libs/gtk+:3[X]
	x11-libs/libnotify
	x11-libs/libX11
	x11-libs/libXScrnSaver
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libxcb
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libXtst
	x11-libs/libxkbcommon
	x11-libs/pango
"

BDEPEND="arm64? ( dev-util/patchelf )"

RESTRICT="bindist mirror splitdebug strip"

src_unpack() {
	if use amd64; then
		cp "${DISTDIR}/${P}-x86_64.AppImage" cherry-studio || die
	elif use arm64; then
		cp "${DISTDIR}/${P}-arm64.AppImage" cherry-studio || die
	fi
}

src_prepare() {
	default

	# The arm64 AppImage runtime is linked against the libz.so linker symlink
	# rather than the libz.so.1 SONAME and retains a build-time RPATH.
	# patchelf relocates the squashfs payload intact after rewriting the ELF.
	if use arm64; then
		patchelf --replace-needed libz.so libz.so.1 --remove-rpath \
			cherry-studio || die
	fi
}

src_install() {
	dobin cherry-studio
	domenu "${FILESDIR}/cherry-studio.desktop"
	doicon -s scalable "${FILESDIR}/cherry-studio.svg"
}

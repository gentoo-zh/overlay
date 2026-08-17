# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion xdg

MY_PN="${PN%-bin}"
# nightly is a rolling tag with in-place assets: no fixed SRC_URI or Manifest
NIGHTLY_TARBALL="${MY_PN}-nightly.Ubuntu22.04.tar.xz"
NIGHTLY_URI="https://github.com/wezterm/${MY_PN}/releases/download/nightly"

DESCRIPTION="A GPU-accelerated cross-platform terminal emulator and multiplexer"
HOMEPAGE="https://wezterm.org/ https://github.com/wezterm/wezterm"
S="${WORKDIR}/${MY_PN}"

LICENSE="MIT OFL-1.1"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 BSD-2 BSD CC0-1.0 ISC LGPL-2.1 MIT MPL-2.0 UoI-NCSA
	Unicode-3.0 Unicode-DFS-2016 WTFPL-2 ZLIB
"
SLOT="0"
KEYWORDS=""
PROPERTIES="live"

RESTRICT="strip"

BDEPEND="net-misc/curl"

# X and Wayland are both in DT_NEEDED; dbus, EGL and xcb-keysyms are dlopened
RDEPEND="
	!x11-terms/wezterm
	dev-libs/openssl:0/3
	dev-libs/wayland
	media-libs/fontconfig
	media-libs/libglvnd
	sys-apps/dbus
	virtual/zlib:=
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libxkbcommon[X]
	x11-libs/xcb-util
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
	x11-themes/hicolor-icon-theme
"

QA_PREBUILT="usr/bin/*"

src_unpack() {
	cd "${T}" || die

	curl -fsSL --retry 3 -O "${NIGHTLY_URI}/${NIGHTLY_TARBALL}" \
		-O "${NIGHTLY_URI}/${NIGHTLY_TARBALL}.sha256" || die "download failed"
	sha256sum -c "${NIGHTLY_TARBALL}.sha256" || die "checksum mismatch"

	cd "${WORKDIR}" || die
	unpack "${T}/${NIGHTLY_TARBALL}"
}

src_install() {
	dozshcomp usr/share/zsh/functions/Completion/Unix/_${MY_PN}
	rm -r usr/share/zsh || die

	insinto /
	doins -r etc usr

	fperms 0755 /usr/bin/{open-wezterm-here,strip-ansi-escapes,${MY_PN},${MY_PN}-gui,${MY_PN}-mux-server}
}

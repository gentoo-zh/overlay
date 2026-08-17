# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion xdg

MY_PN="${PN%-bin}"
MY_PV="${PV}-110809-5046fc22"

DESCRIPTION="A GPU-accelerated cross-platform terminal emulator and multiplexer"
HOMEPAGE="https://wezterm.org/ https://github.com/wezterm/wezterm"
# The Ubuntu 20.04 build links libssl.so.1.1; the 22.04 one links libssl.so.3,
# which is the openssl the tree ships.
SRC_URI="https://github.com/wezterm/${MY_PN}/releases/download/${MY_PV}/${MY_PN}-${MY_PV}.Ubuntu22.04.tar.xz"
S="${WORKDIR}/${MY_PN}"

LICENSE="MIT OFL-1.1"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 BSD-2 BSD CC0-1.0 ISC LGPL-2.1 MIT MPL-2.0 UoI-NCSA
	Unicode-3.0 Unicode-DFS-2016 WTFPL-2 ZLIB
"
SLOT="0"
KEYWORDS="-* ~amd64"

RESTRICT="strip"

# X and Wayland are both in DT_NEEDED, so neither can be a USE flag here.
# libdbus-1, libEGL and libxcb-keysyms are dlopened by wezterm-gui.
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

src_install() {
	dozshcomp usr/share/zsh/functions/Completion/Unix/_${MY_PN}
	rm -r usr/share/zsh || die

	insinto /
	doins -r etc usr

	fperms 0755 /usr/bin/{open-wezterm-here,strip-ansi-escapes,${MY_PN},${MY_PN}-gui,${MY_PN}-mux-server}
}

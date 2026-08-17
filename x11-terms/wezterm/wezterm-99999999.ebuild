# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.93"

inherit cargo desktop git-r3 shell-completion xdg-utils

DESCRIPTION="A GPU-accelerated cross-platform terminal emulator and multiplexer"
HOMEPAGE="https://wezterm.org/ https://github.com/wezterm/wezterm"
EGIT_REPO_URI="https://github.com/wezterm/wezterm.git"

LICENSE="MIT OFL-1.1"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 BSD-2 BSD CC0-1.0 ISC LGPL-2.1 MIT MPL-2.0 UoI-NCSA
	Unicode-3.0 Unicode-DFS-2016 WTFPL-2 ZLIB
"
SLOT="0"
KEYWORDS=""
IUSE="wayland"
RESTRICT="test" # tests require network

DEPEND="
	dev-libs/libgit2
	dev-libs/openssl
	media-fonts/jetbrains-mono
	media-fonts/noto
	media-fonts/noto-emoji
	media-fonts/roboto
	media-libs/fontconfig
	media-libs/libpng
	media-libs/mesa
	sys-apps/dbus
	virtual/zlib
	x11-libs/cairo[X]
	x11-libs/libX11
	x11-libs/libxkbcommon[X,wayland?]
	x11-libs/xcb-imdkit
	x11-libs/xcb-util
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-wm
	x11-themes/hicolor-icon-theme
	x11-themes/xcursor-themes
	wayland? ( dev-libs/wayland )
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-build/cmake
	dev-vcs/git
	virtual/pkgconfig
"

QA_FLAGS_IGNORED="usr/bin/.*"

src_unpack() {
	git-r3_src_unpack
	cargo_live_src_unpack
}

src_configure() {
	local myfeatures=(
		distro-defaults
		vendor-nerd-font-symbols-font
		$(usev wayland)
	)
	cargo_src_configure --no-default-features
}

src_install() {
	exeinto /usr/bin
	doexe "$(cargo_target_dir)"/{wezterm,wezterm-gui,wezterm-mux-server,strip-ansi-escapes}

	insinto /usr/share/icons/hicolor/128x128/apps
	newins assets/icon/terminal.png org.wezfurlong.${PN}.png

	newmenu assets/${PN}.desktop org.wezfurlong.${PN}.desktop

	insinto /usr/share/metainfo
	newins assets/${PN}.appdata.xml org.wezfurlong.${PN}.appdata.xml

	newbashcomp assets/shell-completion/bash ${PN}
	newzshcomp assets/shell-completion/zsh _${PN}
	newfishcomp assets/shell-completion/fish ${PN}.fish
}

pkg_postinst() {
	xdg_icon_cache_update

	einfo "If the mouse cursor theme does not work, set XCURSOR_PATH to the directory"
	einfo "holding the cursor icons, or set xcursor_theme in ~/.wezterm.lua; see"
	einfo "https://wezterm.org/faq.html"
}

pkg_postrm() {
	xdg_icon_cache_update
}

# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg

MY_R="110809-5046fc22"
MY_PV="${PV}-${MY_R}"
MY_PN="${PN/-bin/}"
MY_P="${MY_PN}-${MY_PV}"

DESCRIPTION="A terminal emulator and multiplexer implemented in Rust"
HOMEPAGE="https://wezfurlong.org/wezterm/"

SRC_URI="https://github.com/wezterm/wezterm/releases/download/${MY_PV}/${MY_PN}-${MY_PV}.Ubuntu20.04.tar.xz"

S="${WORKDIR}/${MY_PN}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~amd64"

IUSE="wayland +X"
REQUIRED_USE="|| ( wayland X )"

RDEPEND="
	sys-apps/dbus
	>=media-libs/fontconfig-2.12
	dev-libs/openssl-compat:1.1.1
	wayland? (
		dev-libs/wayland
		dev-libs/wayland-protocols
	)
	X? (
		>=x11-libs/libX11-1.7.5
		>=x11-libs/libxcb-1.8
		>=x11-libs/xcb-util-0.4
		>=x11-libs/xcb-util-wm-0.4.1
		>=x11-libs/xcb-util-image-0.2.1
		>=x11-libs/xcb-util-keysyms-0.4
		x11-libs/libxkbcommon[X]
	)
	x11-themes/hicolor-icon-theme
"

QA_PREBUILT="*"

src_install() {
	insinto /
	doins -r etc usr

	fperms 0755 /usr/bin/{open-wezterm-here,strip-ansi-escapes,wezterm,wezterm-gui,wezterm-mux-server}
	fperms 0755 /etc/profile.d/${MY_PN}.sh
}

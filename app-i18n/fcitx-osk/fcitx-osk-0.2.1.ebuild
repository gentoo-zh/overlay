# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES=""

MY_PN="fcitx5-osk"
MY_P="${MY_PN}-${PV}"
RUST_MIN_VER="1.88.0"

inherit cargo desktop systemd xdg

DESCRIPTION="On-screen keyboard for Fcitx 5, with a KWin Wayland virtual keyboard launcher"
HOMEPAGE="https://github.com/fortime/fcitx5-osk"
SRC_URI="
	https://github.com/fortime/${MY_PN}/archive/refs/tags/${PV}.tar.gz -> ${MY_P}.tar.gz
	https://github.com/gentoo-zh/gentoo-deps/releases/download/${P}/${P}-crates.tar.xz
	${CARGO_CRATE_URIS}
"
S="${WORKDIR}/${MY_P}"

LICENSE="MIT"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 BSD-2 BSD Boost-1.0 CC0-1.0 CDLA-Permissive-2.0 ISC MIT
	UoI-NCSA Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# wayland, libxkbcommon, libEGL and libvulkan are loaded with dlopen.
# The KWin launcher runs kreadconfig6 and kwriteconfig6.
DEPEND="
	dev-libs/openssl:=
"
RDEPEND="
	${DEPEND}
	app-i18n/fcitx:5
	dev-libs/wayland
	kde-frameworks/kconfig:6
	media-fonts/symbols-nerd-font
	media-libs/fontconfig
	media-libs/libglvnd
	media-libs/vulkan-loader
	sys-apps/dbus
	x11-libs/libxkbcommon
"
BDEPEND="
	virtual/pkgconfig
"

src_prepare() {
	default

	local f
	for f in \
		pkg/share/applications/fyi.fortime.Fcitx5Osk.desktop.in \
		pkg/share/applications/fyi.fortime.Fcitx5Osk.KwinLauncher.desktop.in \
		pkg/share/dbus-1/services/fyi.fortime.Fcitx5Osk.service.in \
		pkg/share/dbus-1/services/fyi.fortime.Fcitx5Osk.KwinLauncher.service.in \
		pkg/lib/systemd/system/fcitx5-osk-key-helper.service.in
	do
		sed -e "s|@INSTALL_BIN_DIR@|${EPREFIX}/usr/bin|g" "${f}" > "${f%.in}" || die
	done
}

src_install() {
	local bindir="$(cargo_target_dir)"
	dobin "${bindir}"/fcitx5-osk{,-key-helper,-kwin-launcher}

	domenu pkg/share/applications/fyi.fortime.Fcitx5Osk{,.KwinLauncher}.desktop

	insinto /usr/share/dbus-1/services
	doins pkg/share/dbus-1/services/fyi.fortime.Fcitx5Osk{,.KwinLauncher}.service

	insinto /usr/share/dbus-1/system.d
	doins pkg/share/dbus-1/system.d/fyi.fortime.Fcitx5OskKeyHelper.conf
	systemd_dounit pkg/lib/systemd/system/fcitx5-osk-key-helper.service
	newinitd "${FILESDIR}"/fcitx5-osk-key-helper.initd fcitx5-osk-key-helper

	newicon -s scalable assets/icons/fcitx5-osk.svg fyi.fortime.Fcitx5Osk.svg

	insinto /usr/share/fcitx5-osk
	doins -r pkg/share/fcitx5-osk/.
	insinto /usr/share/fcitx5-osk/examples
	doins -r assets/layouts assets/key_sets

	dosym -r /usr/share/fcitx5-osk/themes/breeze-light.toml \
		/etc/xdg/fcitx5-osk/themes/breeze-light.toml

	dodoc README.md CHANGELOG.md
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "Select \"Fcitx 5 Osk Kwin Launcher\" in System Settings > Keyboard > Virtual Keyboard."
	elog "With the KWin launcher every key goes through the key helper, so enable it:"
	elog "  systemd: systemctl enable --now fcitx5-osk-key-helper"
	elog "  OpenRC:  rc-update add fcitx5-osk-key-helper default"
}

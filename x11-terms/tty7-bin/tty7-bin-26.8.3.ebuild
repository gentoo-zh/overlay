# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

MY_PN="${PN%-bin}"

DESCRIPTION="Terminal workbench with persistent sessions, SSH, and coding agent integration"
HOMEPAGE="https://tty7.io/ https://github.com/l0ng-ai/tty7"
SRC_URI="
	amd64? (
		https://github.com/l0ng-ai/${MY_PN}/releases/download/v${PV}/${MY_PN}-${PV}-linux-x86_64.tar.gz
			-> ${P}-amd64.tar.gz
		https://raw.githubusercontent.com/l0ng-ai/${MY_PN}/v${PV}/assets/app-icon.png
			-> ${P}.png
	)
"
S="${WORKDIR}/${MY_PN}-${PV}-linux-x86_64"

LICENSE="Apache-2.0 BitstreamVera BSD BSD-2 ISC MIT MPL-2.0 Unicode-3.0 ZLIB openssl public-domain"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="+wayland"
REQUIRED_USE="elibc_glibc"

RDEPEND="
	app-crypt/mit-krb5
	media-libs/libglvnd
	>=sys-libs/glibc-2.39
	sys-apps/dbus
	wayland? ( dev-libs/wayland )
	x11-libs/libxcb
	x11-libs/libxkbcommon[X]
	x11-themes/hicolor-icon-theme
"

RESTRICT="strip"
QA_PREBUILT="
	usr/libexec/${MY_PN}/${MY_PN}
	usr/libexec/${MY_PN}/${MY_PN}-app
"

src_install() {
	local install_dir="/usr/libexec/${MY_PN}"

	exeinto "${install_dir}"
	doexe "${MY_PN}" "${MY_PN}-app"

	insinto "${install_dir}"
	doins -r completions

	dosym -r "${install_dir}/${MY_PN}" "/usr/bin/${MY_PN}"
	dosym -r "${install_dir}/${MY_PN}-app" "/usr/bin/${MY_PN}-app"

	make_desktop_entry --eapi9 "${MY_PN}-app" -n tty7 -i tty7 \
		-c "System;TerminalEmulator" -e "StartupWMClass=tty7"
	newicon -s 1024 "${DISTDIR}/${P}.png" "${MY_PN}.png"

	dodoc README.md
}

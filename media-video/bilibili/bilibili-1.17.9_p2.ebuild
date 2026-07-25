# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

MY_PV="${PV/_p/-}"
DESCRIPTION="Based on the Bilibli offcial client to linux version, support roaming"
HOMEPAGE="https://github.com/msojocs/bilibili-linux"
BASE_URI="https://github.com/msojocs/bilibili-linux/releases/download/v${MY_PV}"
FPN="io.github.msojocs.${PN}"
SRC_URI="
	amd64? ( ${BASE_URI}/${FPN}_${MY_PV}_amd64.deb )
	arm64? ( ${BASE_URI}/${FPN}_${MY_PV}_arm64.deb )
"
S="${WORKDIR}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

IUSE="wayland"

RESTRICT="strip"

RDEPEND="
	dev-libs/libinput
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa[gbm(+)]
	x11-libs/gtk+:*
	x11-libs/libdrm
	x11-libs/libxkbcommon
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libxcb
	x11-misc/xdg-utils
	wayland? ( dev-libs/wayland )
	x11-libs/libvdpau
	net-print/cups
	x11-libs/libXtst
"

QA_PREBUILT="*"

src_install() {
	local app_dir="opt/apps/${FPN}/files/bin/app"

	# Drop non-Linux native modules; scanelf cannot handle their .lib archives.
	rm -rf \
		"${app_dir}/app/node_modules/@nut-tree/libnut-darwin" \
		"${app_dir}/app/node_modules/@nut-tree/libnut-win32" \
		"${app_dir}/app.asar.unpacked/node_modules/@nut-tree/libnut-win32" \
		|| die

	insinto "/"
	doins -r "opt"
	doicon -s "scalable" "usr/share/icons/hicolor/scalable/apps/${FPN}.svg"
	domenu "usr/share/applications/${FPN}.desktop"
	fperms +x "/opt/apps/${FPN}/files/bin/bin/bilibili"
	fperms +x "/opt/apps/${FPN}/files/bin/electron/"{electron,chrome_crashpad_handler,chrome-sandbox}
}

pkg_postinst() {
	xdg_pkg_postinst

	if use arm64; then
		elog "arm64 包内的 clipboardy（xsel）、@nut-tree（libnut）、cursor-tool 是"
		elog "amd64 二进制，在 arm64 上无法运行，相关功能（剪贴板、部分输入）不可用。"
	fi
}

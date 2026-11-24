# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop fcaps optfeature xdg

DESCRIPTION="Multi-purpose Steam toolbox (Watt Toolkit, formerly Steam++)"
HOMEPAGE="https://steampp.net/ https://github.com/BeyondDimension/SteamTools"
URI_PREFIX="https://github.com/BeyondDimension/SteamTools/releases/download/${PV}"
SRC_URI="
	amd64? ( ${URI_PREFIX}/Steam%2B%2B_v${PV}_linux_x64_aot.tgz -> ${P}-amd64.tgz )
	arm64? ( ${URI_PREFIX}/Steam%2B%2B_v${PV}_linux_arm64_aot.tgz -> ${P}-arm64.tgz )
"
S="${WORKDIR}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

RDEPEND="
	app-crypt/mit-krb5
	dev-libs/icu
	dev-libs/nss[utils]
	dev-libs/openssl
	media-libs/fontconfig
	sys-auth/polkit
	sys-libs/glibc
	sys-libs/libcap
	x11-misc/xdg-utils
"

QA_PREBUILT="/usr/lib/watt-toolkit/*"

FILECAPS=(
	cap_net_bind_service=ep "/usr/lib/watt-toolkit/modules/Accelerator/Steam++.Accelerator"
)

src_install() {
	local appdir=/usr/lib/watt-toolkit

	exeinto "${appdir}"
	doexe Steam++ libHarfBuzzSharp.so libSkiaSharp.so libe_sqlite3.so

	exeinto "${appdir}/modules/Accelerator"
	doexe modules/Accelerator/Steam++.Accelerator

	exeinto "${appdir}/script"
	doexe script/environment_check.sh

	# the program runs this name from its own directory, also with pkexec
	exeinto "${appdir}"
	newexe "${FILESDIR}"/watt-toolkit-bin.sh Steam++.sh
	dosym ../lib/watt-toolkit/Steam++.sh /usr/bin/watt-toolkit

	newicon -s 512 Icons/Watt-Toolkit.png net.steampp.app.png
	newmenu "${FILESDIR}"/watt-toolkit-bin.desktop net.steampp.app.desktop
}

pkg_postinst() {
	fcaps_pkg_postinst
	xdg_pkg_postinst
	optfeature "making the main feature work (available in Steam overlay)" games-util/steam-launcher
}

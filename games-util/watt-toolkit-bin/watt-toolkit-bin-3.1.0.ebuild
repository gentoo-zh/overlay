# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop fcaps optfeature xdg

DESCRIPTION="Multi-purpose Steam toolbox (Watt Toolkit, formerly Steam++)"
HOMEPAGE="https://steampp.net/ https://github.com/BeyondDimension/SteamTools"
SRC_URI="https://github.com/BeyondDimension/SteamTools/releases/download/${PV}/Steam%2B%2B_v${PV}_linux_x64.tgz -> ${P}.tgz"
S="${WORKDIR}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="-* ~amd64"

RDEPEND="
	dev-libs/nss[utils]
	media-libs/fontconfig
	sys-auth/polkit
	sys-libs/libcap
	virtual/dotnet-sdk:10.0
	x11-misc/xdg-utils
"

QA_PREBUILT="/usr/lib/watt-toolkit/*"

FILECAPS=(
	cap_net_bind_service=ep "/usr/lib/watt-toolkit/modules/Accelerator/Steam++.Accelerator"
)

src_install() {
	local appdir=/usr/lib/watt-toolkit

	insinto "${appdir}"
	doins -r assemblies/* modules native
	fperms 0755 "${appdir}/modules/Accelerator/Steam++.Accelerator"

	insinto "${appdir}/script"
	doins script/environment_check.sh
	fperms 0755 "${appdir}/script/environment_check.sh"

	# the program runs this name from its own directory, with pkexec
	exeinto "${appdir}"
	newexe "${FILESDIR}"/watt-toolkit-bin.sh Steam++.sh
	dosym ../lib/watt-toolkit/Steam++.sh /usr/bin/watt-toolkit

	newicon -s 512 Icons/Watt-Toolkit.png net.steampp.app.png
	newmenu "${FILESDIR}"/watt-toolkit-bin.desktop net.steampp.app.desktop

	# the single-file bundle is appended to this executable, strip truncates it
	dostrip -x /usr/lib/watt-toolkit/modules/Accelerator/Steam++.Accelerator
}

pkg_postinst() {
	fcaps_pkg_postinst
	xdg_pkg_postinst
	optfeature "making the main feature work (available in Steam overlay)" games-util/steam-launcher
}

# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

MY_PN="${PN%-bin}"

DESCRIPTION="A full-featured download manager"
HOMEPAGE="https://github.com/AnInsomniacy/rayburst"
URL_PREFIX="https://github.com/AnInsomniacy/rayburst/releases/download/v${PV}/Rayburst_${PV}"
SRC_URI="
	amd64? ( ${URL_PREFIX}_amd64.AppImage )
	arm64? ( ${URL_PREFIX}_aarch64.AppImage )
"

S="${WORKDIR}"

LICENSE="MIT GPL-2+ LGPL-2+ LGPL-2.1+"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RDEPEND="sys-fs/fuse:0"

RESTRICT="strip"
QA_PREBUILT="usr/bin/${MY_PN}"

src_unpack() {
	if use amd64; then
		cp "${DISTDIR}/Rayburst_${PV}_amd64.AppImage" "${MY_PN}" || die
	elif use arm64; then
		cp "${DISTDIR}/Rayburst_${PV}_aarch64.AppImage" "${MY_PN}" || die
	fi

	chmod +x "${MY_PN}" || die
	./"${MY_PN}" --appimage-extract >/dev/null || die
}

src_install() {
	dobin "${MY_PN}"

	domenu squashfs-root/usr/share/applications/Rayburst.desktop

	for size in 32 128; do
		doicon -s ${size} squashfs-root/usr/share/icons/hicolor/${size}x${size}/apps/${MY_PN}.png
	done
	doicon -s 256 squashfs-root/usr/share/icons/hicolor/256x256@2/apps/${MY_PN}.png
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "Motrix Next settings, tasks and history are not imported into Rayburst."
	elog "Finish active downloads before switching, then uninstall net-misc/motrix-next-bin."
}

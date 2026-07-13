# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

MY_PN="Folo"

DESCRIPTION="Next generation information browser"
HOMEPAGE="
	https://folo.is/
	https://github.com/RSSNext/Folo
"
SRC_URI="
	https://github.com/RSSNext/Folo/releases/download/desktop/v${PV}/${MY_PN}-${PV}-linux-x64.AppImage -> ${P}.AppImage
"

S="${WORKDIR}"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa[gbm(+)]
	sys-apps/dbus
	virtual/libudev:=
	x11-libs/gtk+:3[X,cups]
	x11-libs/libxkbcommon
"

QA_PREBUILT="/opt/folo-bin/*"

src_unpack() {
	mkdir -p "${S}" || die
	cp "${DISTDIR}/${P}.AppImage" "${S}" || die

	cd "${S}" || die         # "appimage-extract" unpacks to current directory.
	chmod +x "${S}/${P}.AppImage" || die
	"${S}/${P}.AppImage" --appimage-extract || die
}

src_install() {
	cd "${S}/squashfs-root" || die

	domenu "${MY_PN}".desktop
	doicon -s 256 usr/share/icons/hicolor/256x256/apps/"${MY_PN}".png

	local toremove=(
		.DirIcon
		"${MY_PN}".desktop
		"${MY_PN}".png
		AppRun
		LICENSES.chromium.html
		usr
	)
	rm -f -r "${toremove[@]}" || die

	local apphome="/opt/${PN}"
	insinto "${apphome}"
	doins -r .

	fperms +x "${apphome}/${MY_PN}"
	dosym -r "${apphome}/${MY_PN}" "/opt/bin/${MY_PN}"
}

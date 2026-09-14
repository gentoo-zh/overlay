# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

MY_PN="${PN%-bin}"

DESCRIPTION="End-to-end encrypted note taking alternative to Evernote"
HOMEPAGE="https://notesnook.com/
	https://github.com/streetwriters/notesnook/"
SRC_URI="
	amd64? (
		https://github.com/streetwriters/${MY_PN}/releases/download/v${PV}/${MY_PN}_linux_x86_64.AppImage
			-> ${P}-amd64.AppImage
	)
	arm64? (
		https://github.com/streetwriters/${MY_PN}/releases/download/v${PV}/${MY_PN}_linux_arm64.AppImage
			-> ${P}-arm64.AppImage
	)
"
S="${WORKDIR}"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

RESTRICT="splitdebug"

RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	sys-libs/glibc
	virtual/libudev
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libnotify
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/pango
"

QA_PREBUILT="*"

src_unpack() {
	local arch=amd64
	use arm64 && arch=arm64

	cp "${DISTDIR}/${P}-${arch}.AppImage" "${MY_PN}" || die
	chmod +x "${MY_PN}" || die
	./"${MY_PN}" --appimage-extract > /dev/null || die
}

src_prepare() {
	default

	local desktop="squashfs-root/${MY_PN}.desktop"

	sed -i "s|^Exec=AppRun|Exec=${MY_PN}|" "${desktop}" || die

	# upstream repeats the scheme handler and ships action groups it never
	# declares, both of which desktop-file-validate rejects
	local actions
	actions=$(sed -nE 's/^\[Desktop Action (.+)\]$/\1;/p' "${desktop}" | tr -d '\n')
	sed -i -e "s|^MimeType=.*|MimeType=x-scheme-handler/nn;|" \
		-e "/^MimeType=/a Actions=${actions}" "${desktop}" || die
}

src_install() {
	cd squashfs-root || die

	dodoc LICENSE.electron.txt LICENSES.chromium.html

	insinto /usr/share
	doins -r usr/share/icons

	domenu "${MY_PN}.desktop"

	rm -r AppRun .DirIcon usr "${MY_PN}.desktop" "${MY_PN}.png" \
		LICENSE.electron.txt LICENSES.chromium.html || die

	local apphome="/opt/${MY_PN}"
	dodir "${apphome}"
	cp -r . "${ED}${apphome}" || die

	# Chrome-sandbox requires the setuid bit to be specifically set.
	# see https://github.com/electron/electron/issues/17972
	fowners root "${apphome}/chrome-sandbox"
	fperms 4711 "${apphome}/chrome-sandbox"

	dosym -r "${apphome}/${MY_PN}" "/usr/bin/${MY_PN}"
}

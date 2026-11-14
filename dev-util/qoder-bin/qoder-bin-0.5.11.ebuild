# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker xdg

DESCRIPTION="Qoder - agent workbench for human and AI software teams"
HOMEPAGE="https://qoder.com/"
SRC_URI="
	amd64? (
		https://download.qoder.com/qoder-app/releases/${PV}/Qoder-linux-amd64.deb -> ${P}-amd64.deb
	)
	arm64? (
		https://download.qoder.com/qoder-app/releases/${PV}/Qoder-linux-arm64.deb -> ${P}-arm64.deb
	)
"

S="${WORKDIR}"

LICENSE="Qoder-EULA"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="mirror bindist"

RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa[opengl]
	net-print/cups
	sys-apps/dbus
	virtual/udev
	x11-libs/cairo
	x11-libs/gtk+:3[X]
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/pango
	x11-misc/xdg-utils
"

QA_PREBUILT="opt/Qoder/*"

src_unpack() {
	:
}

src_install() {
	local myarch

	case ${ARCH} in
		amd64) myarch=x64 ;;
		arm64) myarch=arm64 ;;
		*) die "unsupported ARCH=${ARCH}" ;;
	esac

	dodir /
	cd "${ED}" || die
	unpacker

	rm -rf \
		usr/share/doc \
		"opt/Qoder/resources/app.asar.unpacked/node_modules/@img/sharp-libvips-linuxmusl-${myarch}" \
		"opt/Qoder/resources/app.asar.unpacked/node_modules/@img/sharp-linuxmusl-${myarch}" \
		"opt/Qoder/resources/app.asar.unpacked/node_modules/@napi-rs/canvas-linux-${myarch}-musl" \
		|| die

	dosym ../../opt/Qoder/qoder /usr/bin/qoder
	fperms 4755 /opt/Qoder/chrome-sandbox
	find "${ED}"/opt/Qoder -perm /022 -exec chmod go-w {} + || die
}

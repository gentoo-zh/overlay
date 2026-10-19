# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="ZCode - Z.ai's Agentic Development Environment for GLM (binary package)"
HOMEPAGE="https://zcode.z.ai"
SRC_URI="
	amd64? (
		https://cdn-zcode.z.ai/zcode/electron/releases/${PV}/linux-x64/ZCode-${PV}-linux-x64.AppImage
			-> ${P}-amd64.AppImage
	)
	arm64? (
		https://cdn-zcode.z.ai/zcode/electron/releases/${PV}/linux-arm64/ZCode-${PV}-linux-arm64.AppImage
			-> ${P}-arm64.AppImage
	)
"

S="${WORKDIR}/${P}"

LICENSE="Zcode"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="mirror bindist strip"

QA_PREBUILT="opt/zcode-bin/*"

RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	virtual/libudev
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/pango
"

src_unpack() {
	cp "${DISTDIR}/${A}" . || die
	chmod +x "${A}"
	./"${A}" --appimage-extract >/dev/null || die "appimage-extract failed"
	mv squashfs-root "${P}" || die
}

src_prepare() {
	default
	# The AppImage ships resources/ and its subdirectories as 0700, so only root could start the app.
	chmod -R go+rX . || die
}

src_install() {
	local dest=/opt/zcode-bin
	dodir "${dest}"
	cp -r "${S}"/. "${ED}${dest}" || die
	fperms 4711 "${dest}"/chrome-sandbox

	if use amd64; then
		# Ubuntu tray fallbacks and gconf need GTK2 and dbus-glib; the app does not load them.
		rm "${ED}${dest}"/usr/lib/{libappindicator.so.1,libindicator.so.7,libgconf-2.so.4} || die
		# The amd64 AppImage ships an aarch64 sshcrypto.node; ssh2 falls back to pure JS.
		local ssh2="${ED}${dest}"/resources/app.asar.unpacked/node_modules/ssh2
		rm "${ssh2}"/lib/protocol/crypto/build/Release/sshcrypto.node || die
	fi

	dosym -r "${dest}"/zcode /usr/bin/zcode

	local size
	for size in 48 64 128 256 1024; do
		doicon -s ${size} usr/share/icons/hicolor/${size}x${size}/apps/zcode.png
	done
	make_desktop_entry "zcode %U" "ZCode" zcode "Development;IDE;"
}

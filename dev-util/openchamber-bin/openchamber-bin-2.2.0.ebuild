# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

MY_PN="${PN%-bin}"

DESCRIPTION="Desktop workspace for running and reviewing OpenCode AI coding agents"
HOMEPAGE="https://github.com/openchamber/openchamber"
SRC_URI="
	amd64? (
		https://github.com/openchamber/openchamber/releases/download/v${PV}/OpenChamber-${PV}-linux-x86_64.AppImage
			-> ${P}-amd64.AppImage
	)
	arm64? (
		https://github.com/openchamber/openchamber/releases/download/v${PV}/OpenChamber-${PV}-linux-arm64.AppImage
			-> ${P}-arm64.AppImage
	)
"
S="${WORKDIR}/squashfs-root"

LICENSE="0BSD Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 Base64
	BlueOak-1.0.0 Boost-1.0 CC-BY-3.0 FFT2D FTL IJG ISC
	LGPL-2 LGPL-2.1 MIT MPL-1.1 MPL-2.0 PSF-2 SGI-B-2.0 SunSoft
	Unicode-3.0 Unicode-DFS-2015 Unlicense UoI-NCSA ZLIB libtiff openssl unRAR"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

RDEPEND="
	app-accessibility/at-spi2-core:2
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	dev-vcs/git
	media-libs/alsa-lib
	media-libs/mesa[gbm(+)]
	net-misc/openssh
	net-print/cups
	sys-apps/dbus
	virtual/libudev:0
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
	x11-libs/libnotify
	x11-libs/pango
	x11-misc/xdg-utils
"
BDEPEND="
	dev-util/patchelf
	sys-fs/squashfs-tools
"

QA_PREBUILT="
	opt/${PN}/chrome-sandbox
	opt/${PN}/chrome_crashpad_handler
	opt/${PN}/lib*.so*
	opt/${PN}/${MY_PN}
	opt/${PN}/resources/opencode-cli/opencode
	opt/${PN}/resources/app.asar.unpacked/node_modules/sherpa-onnx-linux-*/*.so
	opt/${PN}/resources/app.asar.unpacked/node_modules/sherpa-onnx-linux-*/sherpa-onnx.node
	opt/${PN}/resources/app.asar.unpacked/node_modules/node-pty/build/Release/pty.node
	opt/${PN}/resources/app.asar.unpacked/node_modules/node-pty/bin/linux-*/node-pty.node
	opt/${PN}/resources/app.asar.unpacked/node_modules/node-pty/prebuilds/linux-*/pty.node
	opt/${PN}/resources/app.asar.unpacked/node_modules/@msgpackr-extract/msgpackr-extract-linux-*/*.glibc.node
"

src_unpack() {
	# The squashfs starts after the ELF section table; do not execute a foreign runtime.
	local header offset
	header=$(LC_ALL=C readelf -h "${DISTDIR}/${A}") || die
	offset=$(awk '
		/Start of section headers/ { start = $5 }
		/Size of section headers/ { size = $5 }
		/Number of section headers/ { count = $5 }
		END { print start + size * count }
	' <<< "${header}") || die
	[[ ${offset} -gt 0 ]] || die "Invalid AppImage squashfs offset"
	unsquashfs -no-progress -o "${offset}" -d "${S}" "${DISTDIR}/${A}" || die
}

src_prepare() {
	default

	local modules="resources/app.asar.unpacked/node_modules" arch=x64 foreign=arm64
	if use arm64; then
		arch=arm64
		foreign=x64
	fi

	# Electron uses node-pty, not Bun; musl and foreign prebuilds are never loaded.
	rm -r "${modules}"/bun-pty "${modules}"/node-pty/prebuilds/{darwin-*,win32-*,linux-${foreign}} || die
	rm "${modules}"/@msgpackr-extract/msgpackr-extract-linux-${arch}/*.musl.node || die

	# The addon needs its sibling libraries, not the upstream CI directory or cwd.
	patchelf --set-rpath '$ORIGIN' "${modules}/sherpa-onnx-linux-${arch}/sherpa-onnx.node" || die

	sed -i -e "s|^Exec=AppRun --no-sandbox %U$|Exec=${MY_PN} %U|" \
		-e '/^X-AppImage-Version=/d' "${MY_PN}.desktop" || die
}

src_install() {
	dodoc LICENSE.electron.txt LICENSES.chromium.html
	domenu "${MY_PN}.desktop"
	doicon -s scalable "usr/share/icons/hicolor/scalable/${MY_PN}.svg"

	dodir /opt/${PN}
	cp -r "${MY_PN}" chrome-sandbox chrome_crashpad_handler \
		*.pak *.bin icudtl.dat lib*.so* vk_swiftshader_icd.json \
		locales resources "${ED}/opt/${PN}/" || die
	fperms 4711 /opt/${PN}/chrome-sandbox
	dosym -r /opt/${PN}/${MY_PN} /usr/bin/${MY_PN}
}

# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CHROMIUM_LANGS="af am ar as az be bg bn bs ca cs cy da de el en-GB en-US es es-419 et eu fa
	fi fil fr fr-CA gl gu he hi hr hu hy id is it ja ka kk km kn ko ky lo lt lv mk ml mn mr
	ms my nb ne nl or pa pl pt-BR pt-PT ro ru si sk sl sq sr sr-Latn sv sw ta te th tr uk ur
	uz vi zh-CN zh-HK zh-TW zu"

inherit chromium-2 desktop pax-utils xdg

MY_PV="${PV/_p/-}"
SRC_URI_PREFIX="https://github.com/ungoogled-software/ungoogled-chromium-portablelinux/releases/download/${MY_PV}"

DESCRIPTION="Chromium without Google web services, tweaks to enhance privacy and more"
HOMEPAGE="https://ungoogled-software.github.io/ https://github.com/ungoogled-software/ungoogled-chromium"
SRC_URI="
	amd64? ( ${SRC_URI_PREFIX}/ungoogled-chromium-${MY_PV}-x86_64_linux.tar.xz )
	arm64? ( ${SRC_URI_PREFIX}/ungoogled-chromium-${MY_PV}-arm64_linux.tar.xz )
"

if [[ "${ARCH}" = "arm64" ]]; then
	S="${WORKDIR}/ungoogled-chromium-${MY_PV}-arm64_linux"
else
	S="${WORKDIR}/ungoogled-chromium-${MY_PV}-x86_64_linux"
fi

LICENSE="Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 Base64 Boost-1.0 CC-BY-3.0
	CC-BY-4.0 Clear-BSD FFT2D FTL IJG ISC LGPL-2 LGPL-2.1 MIT MPL-1.1 MPL-2.0 Ms-PL PSF-2
	SGI-B-2.0 SSLeay SunSoft Unicode-3.0 Unicode-DFS-2015 Unlicense UoI-NCSA ZLIB libtiff
	openssl"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
IUSE="qt6 selinux"

# The binary carries AAC, H.264 and HEVC decoders.
RESTRICT="bindist"

RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-misc/ca-certificates
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	>=dev-libs/nss-3.26
	media-fonts/liberation-fonts
	media-libs/alsa-lib
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	sys-apps/pciutils
	sys-libs/glibc
	virtual/libudev
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3[X]
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/pango
	x11-misc/xdg-utils
	qt6? ( dev-qt/qtbase:6[gui,widgets] )
	selinux? ( sec-policy/selinux-chromium )
"

QA_PREBUILT="opt/ungoogled-chromium/*"

pkg_setup() {
	chromium_suid_sandbox_check_kernel_config
}

src_prepare() {
	default

	pushd locales > /dev/null || die
	chromium_remove_language_paks
	popd > /dev/null || die

	rm libqt5_shim.so || die
	if ! use qt6; then
		rm libqt6_shim.so || die
	fi

	pax-mark m chrome

	cat > ungoogled-chromium <<- EOF || die
		#!/bin/bash
		export CHROME_DESKTOP="ungoogled-chromium.desktop"
		export CHROME_WRAPPER="/opt/bin/ungoogled-chromium"
		exec /opt/ungoogled-chromium/chrome "\$@"
	EOF
}

src_install() {
	exeinto /opt/ungoogled-chromium
	doexe chrome chromedriver chrome_crashpad_handler

	insinto /opt/ungoogled-chromium
	doins -r locales
	doins *.so* *.pak *.bin *.dat vk_swiftshader_icd.json

	exeinto /opt/bin
	doexe ungoogled-chromium

	make_desktop_entry --eapi9 \
		"/opt/bin/ungoogled-chromium" \
		--args "%U" \
		--desktopid "ungoogled-chromium" \
		--name "Ungoogled Chromium" \
		--icon "ungoogled-chromium" \
		--entry "MimeType=application/xhtml+xml;text/html;text/xml;x-scheme-handler/http;x-scheme-handler/https;" \
		--entry "StartupWMClass=ungoogled-chromium"
	newicon -s 48 product_logo_48.png ungoogled-chromium.png
}

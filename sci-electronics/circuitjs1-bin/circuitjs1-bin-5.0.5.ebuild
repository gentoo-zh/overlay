# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN=circuitjs1
# upstream's "ts" suffix marks the TypeScript port (versionString `5.0.5ts`)
MY_PV="${PV}ts"
DESCRIPTION="Electronic Circuit Simulator in the Browser"
HOMEPAGE="https://www.falstad.com/circuit/ https://github.com/sharpie7/circuitjs1"
SRC_URI="https://www.falstad.com/circuit/offline/${MY_PN}-${MY_PV}-linux64.tgz"

S="${WORKDIR}/${MY_PN}"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	app-accessibility/at-spi2-core:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/pango
"

QA_PREBUILT="
	/opt/${PN}/${MY_PN}
	/opt/${PN}/chrome-sandbox
	/opt/${PN}/chrome_crashpad_handler
	/opt/${PN}/libEGL.so
	/opt/${PN}/libGLESv2.so
	/opt/${PN}/libffmpeg.so
	/opt/${PN}/libvk_swiftshader.so
	/opt/${PN}/libvulkan.so.1
"

src_prepare() {
	default
	# Upstream repackages the offline build on macOS, so the tarball carries
	# AppleDouble (._*) sidecar files; drop them so they are not installed.
	find . -name '._*' -delete || die
}

src_install() {
	insinto "/opt/${PN}"
	doins -r .
	fperms 0755 "/opt/${PN}/${MY_PN}" "/opt/${PN}/chrome_crashpad_handler"
	dosym "../../opt/${PN}/${MY_PN}" "/usr/bin/${MY_PN}"
}
